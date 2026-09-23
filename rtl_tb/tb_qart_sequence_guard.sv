module tb_qart_sequence_guard;
 logic clk=0,rst_n=0,accept=0,resync=0; logic [31:0] seq=0,resync_value=0,expected_seq; logic seq_ok;
 always #1 clk=~clk;
 qart_sequence_guard dut(.*);
 task tick; begin @(negedge clk); @(posedge clk); #0; end endtask
 initial begin
  repeat(2) tick(); rst_n=1; #1;
  if(expected_seq!==0||!seq_ok) $fatal(1,"reset sequence state");
  accept=1; tick(); accept=0; #1; if(expected_seq!==1) $fatal(1,"accept did not increment");
  seq=0; #1; if(seq_ok) $fatal(1,"duplicate accepted");
  accept=1; tick(); accept=0; #1; if(expected_seq!==1) $fatal(1,"duplicate changed state");
  seq=2; #1; if(seq_ok) $fatal(1,"gap accepted");
  accept=1; tick(); accept=0; #1; if(expected_seq!==1) $fatal(1,"gap changed state");
  seq=1; #1; if(!seq_ok) $fatal(1,"expected sequence rejected");
  accept=1; tick(); accept=0; #1; if(expected_seq!==2) $fatal(1,"second accept failed");
  resync_value=32'hffffffff;resync=1;tick();resync=0;#1;if(expected_seq!==32'hffffffff)$fatal(1,"resync failed");
  seq=32'hffffffff;accept=1;tick();accept=0;#1;if(expected_seq!==0)$fatal(1,"wrap failed");
  $display("QART_SEQUENCE_GUARD_PASS");$finish;
 end
endmodule
