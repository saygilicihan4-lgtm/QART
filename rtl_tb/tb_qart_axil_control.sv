module tb_qart_axil_control;
 logic clk=0,rst_n=0;
 logic[5:0]awaddr=0,araddr=0; logic awvalid=0,awready;
 logic[31:0]wdata=0;logic[3:0]wstrb=0;logic wvalid=0,wready;
 logic[1:0]bresp;logic bvalid,bready=1;
 logic arvalid=0,arready;logic[31:0]rdata;logic[1:0]rresp;logic rvalid,rready=1;
 logic arm,clear_fault,resync;logic[31:0]resync_value;
 logic[31:0]status_flags=32'h0000000e,expected_seq=32'h12345678;

 always #1 clk=~clk;
 qart_axil_control dut(
  .aclk(clk),.aresetn(rst_n),
  .s_axil_awaddr(awaddr),.s_axil_awvalid(awvalid),.s_axil_awready(awready),
  .s_axil_wdata(wdata),.s_axil_wstrb(wstrb),.s_axil_wvalid(wvalid),.s_axil_wready(wready),
  .s_axil_bresp(bresp),.s_axil_bvalid(bvalid),.s_axil_bready(bready),
  .s_axil_araddr(araddr),.s_axil_arvalid(arvalid),.s_axil_arready(arready),
  .s_axil_rdata(rdata),.s_axil_rresp(rresp),.s_axil_rvalid(rvalid),.s_axil_rready(rready),
  .arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),
  .status_flags(status_flags),.expected_seq(expected_seq)
 );

 task wr(input[5:0]a,input[31:0]d,input[3:0]s);
  begin
   @(negedge clk);awaddr=a;wdata=d;wstrb=s;awvalid=1;wvalid=1;
   while(!(awready&&wready)) @(negedge clk);
   @(negedge clk);awvalid=0;wvalid=0;
   while(!bvalid) @(negedge clk);
   if(bresp!==0)$fatal(1,"write SLVERR addr=%h",a);
  end
 endtask
 task wr_split(input[5:0]a,input[31:0]d,input[3:0]s,input bit addr_first);
  begin
   if(addr_first) begin
    @(negedge clk);awaddr=a;awvalid=1;
    while(!awready) @(negedge clk);
    @(negedge clk);awvalid=0;
    repeat(2) @(negedge clk);
    wdata=d;wstrb=s;wvalid=1;
    while(!wready) @(negedge clk);
    @(negedge clk);wvalid=0;
   end else begin
    @(negedge clk);wdata=d;wstrb=s;wvalid=1;
    while(!wready) @(negedge clk);
    @(negedge clk);wvalid=0;
    repeat(2) @(negedge clk);
    awaddr=a;awvalid=1;
    while(!awready) @(negedge clk);
    @(negedge clk);awvalid=0;
   end
   while(!bvalid) @(negedge clk);
   if(bresp!==0)$fatal(1,"split write SLVERR addr=%h",a);
  end
 endtask
 task wr_err(input[5:0]a);
  begin
   @(negedge clk);awaddr=a;wdata=32'hdeadbeef;wstrb=4'hf;awvalid=1;wvalid=1;
   while(!(awready&&wready)) @(negedge clk);
   @(negedge clk);awvalid=0;wvalid=0;
   while(!bvalid) @(negedge clk);
   if(bresp!==2'b10)$fatal(1,"unmapped write did not SLVERR");
  end
 endtask
 task rd_err(input[5:0]a);
  begin
   @(negedge clk);araddr=a;arvalid=1;while(!arready)@(negedge clk);
   @(negedge clk);arvalid=0;while(!rvalid)@(negedge clk);
   if(rresp!==2'b10)$fatal(1,"unmapped read did not SLVERR");
  end
 endtask
 task rd(input[5:0]a,input[31:0]expected_data);
  begin
   @(negedge clk);araddr=a;arvalid=1;
   while(!arready) @(negedge clk);
   @(negedge clk);arvalid=0;
   while(!rvalid) @(negedge clk);
   if(rresp!==0 || rdata!==expected_data)$fatal(1,"read mismatch addr=%h got=%h expected_data=%h",a,rdata,expected_data);
  end
 endtask

 initial begin
  repeat(3)@(posedge clk);rst_n=1;
  rd(6'h00,32'h51415254);
  rd(6'h04,32'h00020000);
  wr(6'h08,32'h1,4'h1);
  if(!arm)$fatal(1,"arm did not persist");
  wr(6'h14,32'h89abcdef,4'hf);
  if(resync_value!==32'h89abcdef)$fatal(1,"resync value mismatch");
  wr(6'h08,32'h7,4'h1);
  if(!clear_fault || !resync)$fatal(1,"control pulses missing");
  @(posedge clk);#1;
  if(clear_fault || resync)$fatal(1,"control pulse lasted more than one cycle");
  rd(6'h0c,32'h0000000e);
  rd(6'h10,32'h12345678);
  rd(6'h14,32'h89abcdef);
  wr(6'h08,32'h0,4'h1);
  if(arm)$fatal(1,"arm did not clear");
  // Independent AW/W channels: both legal orderings.
  wr_split(6'h08,32'h1,4'h1,1'b1);
  if(!arm)$fatal(1,"AW-before-W failed");
  wr_split(6'h08,32'h0,4'h1,1'b0);
  if(arm)$fatal(1,"W-before-AW failed");
  // Byte strobes must update only selected RESYNC_VALUE bytes.
  wr(6'h14,32'h11223344,4'hf);
  wr(6'h14,32'haa00cc00,4'b1010);
  if(resync_value!==32'haa22cc44)$fatal(1,"WSTRB partial write mismatch %h",resync_value);
  rd(6'h14,32'haa22cc44);
  // Unmapped addresses are fail-closed at the bus boundary.
  wr_err(6'h18);
  rd_err(6'h18);
  $display("QART_AXIL_CONTROL_PASS");
  $finish;
 end
endmodule
