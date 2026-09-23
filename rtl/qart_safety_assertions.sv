module qart_safety_assertions(
 input logic clk,rst_n,frame_valid,permit,fault,
 input logic [31:0] magic,seq,expected_seq,
 input logic [7:0] version,kind,
 input logic [15:0] channel,action,amplitude,duration,
 input logic crc_ok
);
 property permit_implies_valid;
  @(posedge clk) disable iff(!rst_n)
  permit |-> (frame_valid && magic==32'h51484150 && version==8'd2 &&
             kind inside {[1:4]} && crc_ok && seq==expected_seq &&
             channel<64 && action<=2 && amplitude<=16'h7fff && duration>=1);
 endproperty
 property fault_blocks_permit;
  @(posedge clk) disable iff(!rst_n) fault |-> !permit;
 endproperty
 assert property(permit_implies_valid);
 assert property(fault_blocks_permit);
endmodule
