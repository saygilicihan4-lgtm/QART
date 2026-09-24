module tb_qart_qhap_ingress_top;
 logic clk=0,rst_n=0,arm=0,clear_fault=0,resync=0;logic[31:0]resync_value=0,d;logic[3:0]keep=4'hf;logic v=0,r,last=0,permit,fault,safe_noop;logic[31:0]expected_seq;logic[31:0]mem[0:7];
 always #1 clk=~clk;
 qart_qhap_ingress_top #(.WATCHDOG_CYCLES(64)) dut(.clk(clk),.rst_n(rst_n),.arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),.s_axis_tdata(d),.s_axis_tkeep(keep),.s_axis_tvalid(v),.s_axis_tready(r),.s_axis_tlast(last),.permit(permit),.fault(fault),.safe_noop(safe_noop),.expected_seq(expected_seq));
 task sendbeat(input[31:0]x,input bit l);begin @(negedge clk);d=x;v=1;last=l;@(negedge clk);v=0;last=0;repeat(6)@(posedge clk);end endtask
 task send_fullrate; begin
  @(negedge clk); v=1; keep=4'hf;
  for(integer j=0;j<8;j++) begin d=mem[j]; last=(j==7); @(negedge clk); end
  v=0; last=0;
 end endtask
 initial begin
  $readmemh("tests/qhap_e2e_words.hex",mem);repeat(3)@(posedge clk);rst_n=1;arm=1;clear_fault=1;@(posedge clk);clear_fault=0;
  for(integer i=0;i<8;i++)sendbeat(mem[i],i==7);
  // CRC stream serializes bytes, so allow it to settle before a second replay probe.
  repeat(8)@(posedge clk);
  $display("AUTONOMOUS_DEBUG expseq=%0d permit=%0b fault=%0b noop=%0b fp=%0b crcdone=%0b crcready=%0b rxv=%0b rxf=%0b crccalc=%08x crcword=%08x magic=%08x seq=%0d kind=%0d",expected_seq,permit,fault,safe_noop,dut.frame_pending,dut.crc_done_latched,dut.crc_ready,dut.rx_valid,dut.rx_fault,dut.crc_calc,dut.crc_word_latched,dut.magic,dut.seq,dut.kind); if(expected_seq!==1)$fatal(1,"valid Python frame did not advance sequence: %0d",expected_seq);
  // Resync to the next sequence and prove full-rate, gapless AXI ingress.
  @(negedge clk);resync_value=32'd0;resync=1;@(negedge clk);resync=0;
  send_fullrate(); repeat(8)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"full-rate AXI frame did not authorize: %0d",expected_seq);
  // Replay exact sequence 0: must never advance state.
  for(integer i=0;i<8;i++)sendbeat(mem[i],i==7);
  repeat(8)@(posedge clk);if(expected_seq!==1)$fatal(1,"replay advanced sequence");
  // Malformed AXI keep must not advance state.
  @(negedge clk);d=mem[0];keep=4'h7;v=1;last=0;@(negedge clk);v=0;keep=4'hf;repeat(4)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"malformed AXI advanced sequence");
  // Corrupt payload without repairing CRC: must fail closed.
  mem[5]=mem[5]^32'h00000001;
  for(integer i=0;i<8;i++)sendbeat(mem[i],i==7);
  repeat(8)@(posedge clk);if(expected_seq!==1)$fatal(1,"payload corruption advanced sequence");
  mem[5]=mem[5]^32'h00000001;
  // Early TLAST must never authorize a partial frame.
  for(integer i=0;i<4;i++)sendbeat(mem[i],i==3);
  repeat(8)@(posedge clk);if(expected_seq!==1)$fatal(1,"early TLAST advanced sequence");
  // Sequence gap: rewrite seq word only; CRC becomes invalid too and must fail closed.
  mem[2]=32'd2;
  for(integer i=0;i<8;i++)sendbeat(mem[i],i==7);
  repeat(8)@(posedge clk);if(expected_seq!==1)$fatal(1,"sequence gap advanced sequence");
  mem[2]=32'd0;
  // Host-loss watchdog: after silence, execution must remain fail-closed.
  repeat(80) @(posedge clk);
  if(!fault || !safe_noop) $fatal(1,"watchdog silence did not force fail-closed safe NOOP");
  if(expected_seq!==1) $fatal(1,"watchdog silence changed sequence state");
  $display("QART_QHAP_AUTONOMOUS_INGRESS_PASS");$finish;
 end
endmodule
