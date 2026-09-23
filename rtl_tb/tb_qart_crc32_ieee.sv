module tb_qart_crc32_ieee;
 logic clk=0,rst_n=0,init=0,valid=0; logic [7:0] data; logic [31:0] crc;
 always #1 clk=~clk;
 qart_crc32_ieee dut(.*);
 task put(input [7:0] b); begin
  @(negedge clk); data=b; valid=1;
  @(negedge clk); valid=0;
 end endtask
 initial begin
  data=0; repeat(2) @(negedge clk); rst_n=1;
  // Canonical CRC-32/ISO-HDLC check: ASCII "123456789" => CBF43926.
  put("1");put("2");put("3");put("4");put("5");put("6");put("7");put("8");put("9");
  #1; if(crc!==32'hCBF43926) $fatal(1,"CRC mismatch: %08x",crc);
  $display("QART_CRC32_TEST_PASS %08x",crc); $finish;
 end
endmodule
