module tb_qart_qhap_crc_stream;
 logic clk=0,rst_n=0,start=0,beat_valid=0,ready;logic[31:0]tdata;logic[2:0]beat_index;logic[31:0]crc;logic[31:0]mem[0:7];always #1 clk=~clk;
 qart_qhap_crc_stream dut(.*);
 initial begin
  $readmemh("tests/qhap_e2e_words.hex",mem);
  repeat(2)@(posedge clk);rst_n=1;start=1;@(posedge clk);start=0;
  for(integer i=0;i<7;i++)begin @(negedge clk);tdata=mem[i];beat_index=i;beat_valid=1;@(posedge clk);@(negedge clk);beat_valid=0;repeat(5)@(posedge clk);end
  #1;if(crc!==mem[7])$fatal(1,"RTL stream CRC mismatch got=%08x expected=%08x",crc,mem[7]);
  $display("QHAP_RTL_STREAM_CRC_PASS %08x",crc);$finish;
 end
endmodule
