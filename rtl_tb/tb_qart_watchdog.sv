module tb_qart_watchdog;
 logic clk=0,rst_n=0,kick=0,arm=0,clear_fault=0,expired,safe_noop; always #1 clk=~clk;
 qart_watchdog #(.TIMEOUT_CYCLES(4)) dut(.*);
 task cycle; begin @(posedge clk); #1; end endtask
 initial begin
  cycle(); if(!safe_noop) $fatal(1,"reset must be safe NOOP");
  rst_n=1; arm=1; kick=1; cycle(); kick=0;
  repeat(3) begin cycle(); if(expired) $fatal(1,"expired too early"); end
  cycle(); if(!expired||!safe_noop) $fatal(1,"timeout did not fail closed");
  kick=1; cycle(); kick=0; if(!expired) $fatal(1,"kick cleared latched fault");
  clear_fault=1;cycle();clear_fault=0;if(expired) $fatal(1,"explicit clear failed");
  kick=1;cycle();kick=0; repeat(2) cycle(); kick=1;cycle();kick=0; if(expired)$fatal(1,"healthy kick expired");
  arm=0;repeat(6)cycle();if(expired)$fatal(1,"disarmed watchdog expired");
  $display("QART_WATCHDOG_PASS");$finish;
 end
endmodule
