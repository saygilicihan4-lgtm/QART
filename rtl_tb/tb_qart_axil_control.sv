module tb_qart_axil_control;
 logic clk=0,rst_n=0;
 logic[5:0]awaddr=0,araddr=0; logic awvalid=0,awready;
 logic[31:0]wdata=0;logic[3:0]wstrb=0;logic wvalid=0,wready;
 logic[1:0]bresp;logic bvalid,bready=1;
 logic arvalid=0,arready;logic[31:0]rdata;logic[1:0]rresp;logic rvalid,rready=1;
 logic arm,clear_fault,resync;logic[31:0]resync_value;
 logic[31:0]status_flags=32'h0000000e,expected_dataed_seq=32'h12345678;

 always #1 clk=~clk;
 qart_axil_control dut(
  .aclk(clk),.aresetn(rst_n),
  .s_axil_awaddr(awaddr),.s_axil_awvalid(awvalid),.s_axil_awready(awready),
  .s_axil_wdata(wdata),.s_axil_wstrb(wstrb),.s_axil_wvalid(wvalid),.s_axil_wready(wready),
  .s_axil_bresp(bresp),.s_axil_bvalid(bvalid),.s_axil_bready(bready),
  .s_axil_araddr(araddr),.s_axil_arvalid(arvalid),.s_axil_arready(arready),
  .s_axil_rdata(rdata),.s_axil_rresp(rresp),.s_axil_rvalid(rvalid),.s_axil_rready(rready),
  .arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),
  .status_flags(status_flags),.expected_dataed_seq(expected_dataed_seq)
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
  $display("QART_AXIL_CONTROL_PASS");
  $finish;
 end
endmodule
