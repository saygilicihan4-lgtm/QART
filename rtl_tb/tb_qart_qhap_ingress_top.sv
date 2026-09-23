module tb_qart_qhap_ingress_top;
 logic clk=0,rst_n=0,arm=0,clear_fault=0,resync=0;logic[31:0]resync_value=0,d;logic[3:0]keep=4'hf;logic v=0,r,last=0,permit,fault,safe_noop;logic[31:0]expected_seq;logic[31:0]mem[0:7];
 always #1 clk=~clk;
 qart_qhap_ingress_top #(.WATCHDOG_CYCLES(64)) dut(.clk(clk),.rst_n(rst_n),.arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),.s_axis_tdata(d),.s_axis_tkeep(keep),.s_axis_tvalid(v),.s_axis_tready(r),.s_axis_tlast(last),.permit(permit),.fault(fault),.safe_noop(safe_noop),.expected_seq(expected_seq));
 task sendbeat(input[31:0]x,input bit l);begin @(negedge clk);d=x;v=1;last=l;@(negedge clk);v=0;last=0;repeat(6)@(posedge clk);end endtask
 initial begin
  $readmemh("tests/qhap_e2e_words.hex",mem);repeat(3)@(posedge clk);rst_n=1;arm=1;clear_fault=1;@(posedge clk);clear_fault=0;
  for(integer i=0;i<8;i++)sendbeat(mem[i],i==7);
  // CRC stream serializes bytes, so allow it to settle before a second replay probe.
  repeat(8)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"valid Python frame did not advance sequence: %0d",expected_seq);
  // Replay exact sequence 0: must never advance state.
  for(integer i=0;i<8;i++)sendbeat(mem[i],i==7);
  repeat(8)@(posedge clk);if(expected_seq!==1)$fatal(1,"replay advanced sequence");
  // Malformed AXI keep must not advance state.
  @(negedge clk);d=mem[0];keep=4'h7;v=1;last=0;@(negedge clk);v=0;keep=4'hf;repeat(4)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"malformed AXI advanced sequence");
  $display("QART_QHAP_AUTONOMOUS_INGRESS_PASS");$finish;
 end
endmodule
