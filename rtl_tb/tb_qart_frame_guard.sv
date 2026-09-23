module tb_qart_frame_guard;
 logic valid,crc_ok,permit,fault; logic [31:0] magic,seq,expected_seq;
 logic [7:0] version,kind; logic [15:0] channel,action,amplitude,duration;
 qart_frame_guard dut(.*);
 task check(input bit want_permit);
  #1;
  if(permit!==want_permit || fault===want_permit) begin
    $display("FAIL permit=%0b fault=%0b expected=%0b",permit,fault,want_permit); $fatal(1);
  end
 endtask
 initial begin
  valid=1;magic=32'h51484150;version=2;kind=1;seq=1;expected_seq=1;
  channel=3;action=1;amplitude=16'h4000;duration=16'd100;crc_ok=1;
  check(1);
  crc_ok=0; check(0); crc_ok=1;
  seq=2; check(0); seq=1;
  channel=64; check(0); channel=3;
  action=3; check(0); action=1;
  amplitude=16'h8000; check(0); amplitude=16'h4000;
  duration=0; check(0); duration=100;
  magic=0; check(0);
  $display("QART_FRAME_GUARD_TEST_PASS"); $finish;
 end
endmodule
