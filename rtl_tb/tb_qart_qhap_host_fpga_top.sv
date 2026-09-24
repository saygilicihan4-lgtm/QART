module tb_qart_qhap_host_fpga_top;
 logic clk=0,resetn=0,arm=0,clear_fault=0,resync=0;
 logic[31:0]resync_value=0,host_data=0,expected_seq;
 logic[3:0]host_keep=4'hf;
 logic host_valid=0,host_ready,host_last=0;
 logic permit,fault,safe_noop,transport_fault;
 logic[31:0]mem[0:7];

 always #1 clk=~clk;

 qart_qhap_host_fpga_top #(.WATCHDOG_CYCLES(128)) dut(
  .qhap_clk(clk),.qhap_resetn(resetn),
  .arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),
  .host_valid(host_valid),.host_ready(host_ready),.host_data(host_data),.host_keep(host_keep),.host_last(host_last),
  .permit(permit),.fault(fault),.safe_noop(safe_noop),.transport_fault(transport_fault),.expected_seq(expected_seq)
 );

 task send_word(input[31:0]x,input bit l);
  begin
   @(negedge clk);
   while(!host_ready) @(negedge clk);
   host_data=x;host_last=l;host_valid=1;
   @(negedge clk);
   host_valid=0;host_last=0;
  end
 endtask

 initial begin
  $readmemh("tests/qhap_e2e_words.hex",mem);
  repeat(3)@(posedge clk);
  resetn=1;
  repeat(4)@(posedge clk);
  arm=1;
  clear_fault=1;
  @(posedge clk);
  clear_fault=0;

  // Python golden frame must cross host bridge and authorize exactly once.
  for(integer i=0;i<8;i++) send_word(mem[i],i==7);
  repeat(12)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"host-to-QHAP golden frame did not advance sequence: %0d",expected_seq);
  if(transport_fault)$fatal(1,"unexpected transport fault on golden frame");

  // Replay through the complete host path must not advance sequence.
  for(integer i=0;i<8;i++) send_word(mem[i],i==7);
  repeat(12)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"host-path replay advanced sequence");

  $display("QART_HOST_TO_QHAP_E2E_PASS");
  $finish;
 end
endmodule
