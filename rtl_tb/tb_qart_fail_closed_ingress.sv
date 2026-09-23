module tb_qart_fail_closed_ingress;
 logic clk=0,rst_n=0,arm=0,clear_fault=0,resync=0,frame_valid=0,protocol_ok=1,crc_ok=1;
 logic [31:0] resync_value=0,magic=32'h51484150,seq=0; logic [7:0] version=2,kind=1;
 logic [15:0] channel=1,action=1,amplitude=16'h4000,duration=100; logic permit,fault,safe_noop; logic [31:0] expected_seq;
 always #1 clk=~clk;
 qart_fail_closed_ingress #(.WATCHDOG_CYCLES(4)) dut(.*);
 task pulse; begin @(negedge clk);frame_valid=1;@(posedge clk);#0;if(!permit)$fatal(1,"valid command denied");@(negedge clk);frame_valid=0;end endtask
 initial begin
  repeat(2) @(posedge clk); rst_n=1;arm=1;clear_fault=1;@(posedge clk);clear_fault=0;
  pulse(); if(expected_seq!==1)$fatal(1,"sequence did not advance");
  seq=0;frame_valid=1;#1;if(permit||!fault||!safe_noop)$fatal(1,"replay not fail closed");frame_valid=0;
  seq=1;crc_ok=0;frame_valid=1;#1;if(permit||!fault||!safe_noop)$fatal(1,"bad crc not fail closed");frame_valid=0;crc_ok=1;
  clear_fault=1;@(posedge clk);clear_fault=0;
  seq=1;pulse(); if(expected_seq!==2)$fatal(1,"recovery sequence failed");
  frame_valid=0;repeat(5) @(posedge clk);#0;if(!fault||!safe_noop||permit)$fatal(1,"watchdog did not force NOOP");
  $display("QART_FAIL_CLOSED_INGRESS_PASS");$finish;
 end
endmodule
