module tb_qart_qhap_ingress_top;
 logic clk=0,rst_n=0,arm=0,clear_fault=0,resync=0;
 logic[31:0]resync_value=0,d;
 logic[3:0]keep=4'hf;
 logic v=0,r,last=0,permit,fault,safe_noop;
 logic[31:0]expected_seq;
 logic[31:0]mem[0:7],mem1[0:7],mem3[0:7];

 always #1 clk=~clk;

 qart_qhap_ingress_top #(.WATCHDOG_CYCLES(64)) dut(
  .clk(clk),.rst_n(rst_n),.arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),
  .s_axis_tdata(d),.s_axis_tkeep(keep),.s_axis_tvalid(v),.s_axis_tready(r),.s_axis_tlast(last),
  .permit(permit),.fault(fault),.safe_noop(safe_noop),.expected_seq(expected_seq)
 );

 task sendbeat(input[31:0]x,input bit l);
  begin
   @(negedge clk);d=x;v=1;last=l;
   @(negedge clk);v=0;last=0;
   repeat(6)@(posedge clk);
  end
 endtask

 task send_fullrate;
  begin
   @(negedge clk);v=1;keep=4'hf;
   for(integer j=0;j<8;j++) begin
    d=mem[j];last=(j==7);@(negedge clk);
   end
   v=0;last=0;
  end
 endtask

 task pulse_clear;
  begin
   @(negedge clk);clear_fault=1;
   @(negedge clk);clear_fault=0;
   repeat(2)@(posedge clk);
  end
 endtask

 initial begin
  $readmemh("tests/qhap_e2e_words.hex",mem);
  $readmemh("tests/qhap_e2e_words_seq1.hex",mem1);
  $readmemh("tests/qhap_e2e_words_seq3.hex",mem3);

  repeat(3)@(posedge clk);
  rst_n=1;arm=1;clear_fault=1;
  @(posedge clk);clear_fault=0;

  for(integer i=0;i<8;i++)sendbeat(mem[i],i==7);
  repeat(8)@(posedge clk);
  $display("AUTONOMOUS_DEBUG expseq=%0d permit=%0b fault=%0b noop=%0b fp=%0b crcdone=%0b crcready=%0b rxv=%0b rxf=%0b crccalc=%08x crcword=%08x magic=%08x seq=%0d kind=%0d",
   expected_seq,permit,fault,safe_noop,dut.frame_pending,dut.crc_done_latched,dut.crc_ready,dut.rx_valid,dut.rx_fault,dut.crc_calc,dut.crc_word_latched,dut.magic,dut.seq,dut.kind);
  if(expected_seq!==1)$fatal(1,"valid Python frame did not advance sequence: %0d",expected_seq);

  // Prove full-rate, gapless AXI ingress.
  @(negedge clk);resync_value=32'd0;resync=1;
  @(negedge clk);resync=0;
  send_fullrate();
  repeat(8)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"full-rate AXI frame did not authorize: %0d",expected_seq);

  // Exact replay must never advance state.
  for(integer i=0;i<8;i++)sendbeat(mem[i],i==7);
  repeat(8)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"replay advanced sequence");

  // Malformed tkeep must become an externally visible fail-closed fault.
  @(negedge clk);d=mem[0];keep=4'h7;v=1;last=0;
  @(negedge clk);v=0;keep=4'hf;
  repeat(4)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"malformed AXI advanced sequence");
  if(!fault || !safe_noop)$fatal(1,"malformed tkeep was not latched fail-closed");
  pulse_clear();

  // Early TLAST must fail closed and not authorize a partial frame.
  for(integer i=0;i<4;i++)sendbeat(mem[i],i==3);
  repeat(4)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"early TLAST advanced sequence");
  if(!fault || !safe_noop)$fatal(1,"early TLAST was not latched fail-closed");
  pulse_clear();

  // Missing TLAST on beat 7 must also fail closed.
  for(integer i=0;i<8;i++)sendbeat(mem[i],1'b0);
  repeat(4)@(posedge clk);
  if(expected_seq!==1)$fatal(1,"missing TLAST advanced sequence");
  if(!fault || !safe_noop)$fatal(1,"missing TLAST was not latched fail-closed");
  pulse_clear();

  // After an explicit clear, a valid next sequence must recover normally.
  for(integer i=0;i<8;i++)sendbeat(mem1[i],i==7);
  repeat(8)@(posedge clk);
  if(expected_seq!==2)$fatal(1,"valid recovery frame did not advance sequence: %0d",expected_seq);

  // Corrupt payload without repairing CRC: must fail closed without advancing.
  mem1[5]=mem1[5]^32'h00000001;
  for(integer i=0;i<8;i++)sendbeat(mem1[i],i==7);
  repeat(8)@(posedge clk);
  if(expected_seq!==2)$fatal(1,"payload corruption advanced sequence");
  mem1[5]=mem1[5]^32'h00000001;

  // Pure sequence gap with a valid CRC must fail closed.
  for(integer i=0;i<8;i++)sendbeat(mem3[i],i==7);
  repeat(8)@(posedge clk);
  if(expected_seq!==2)$fatal(1,"valid-CRC sequence gap advanced sequence");

  // Host-loss watchdog must force safe NOOP after silence.
  repeat(80)@(posedge clk);
  if(!fault || !safe_noop)$fatal(1,"watchdog silence did not force fail-closed safe NOOP");
  if(expected_seq!==2)$fatal(1,"watchdog silence changed sequence state");

  $display("QART_QHAP_AUTONOMOUS_INGRESS_PASS");
  $finish;
 end
endmodule
