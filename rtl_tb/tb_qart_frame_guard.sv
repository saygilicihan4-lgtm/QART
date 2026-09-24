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
  // Telemetry/ACK/fault frames are protocol-valid but must never authorize command execution.
  kind=2; check(0); kind=3; check(0); kind=4; check(0); kind=1;
  seq=2; check(0); seq=1;
  channel=64; check(0); channel=3;
  action=3; check(0); action=1;
  amplitude=16'h8000; check(0); amplitude=16'h4000;
  duration=0; check(0); duration=100;
  magic=0; check(0); magic=32'h51484150;
  // Deterministic RTL fault campaign: 10,000 invalid command states must all fail closed.
  for(integer i=0;i<1000000;i++) begin
    valid=1;version=2;kind=1;seq=32'd1;expected_seq=32'd1;channel=3;action=1;amplitude=16'h4000;duration=100;crc_ok=1;
    case(i%8)
      0: crc_ok=0;
      1: seq=32'd2+(i/8);
      2: channel=16'd64+(i%128);
      3: action=16'd3+(i%8);
      4: amplitude=16'h8000|(i&16'h7fff);
      5: duration=0;
      6: kind=8'd2+(i%3);
      7: magic=32'h51484150 ^ (32'h1 << (i%32));
    endcase
    check(0);
    magic=32'h51484150;
  end
  $display("QART_FRAME_GUARD_1M_FAULT_CAMPAIGN_PASS");
  $display("QART_FRAME_GUARD_TEST_PASS"); $finish;
 end
endmodule
