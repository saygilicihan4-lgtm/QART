module qart_frame_guard(
 input logic valid,
 input logic [31:0] magic,
 input logic [7:0] version,
 input logic [7:0] kind,
 input logic [31:0] seq,
 input logic [15:0] channel,action,amplitude,duration,
 input logic crc_ok,
 input logic [31:0] expected_seq,
 output logic permit,
 output logic fault
);
always_comb begin
 permit=1'b0; fault=1'b1;
 if(valid && magic==32'h51484150 && version==8'd2 &&
    kind>=1 && kind<=4 && crc_ok && seq==expected_seq &&
    channel<64 && action<=2 && amplitude<=16'h7fff && duration>=1) begin
   permit=1'b1; fault=1'b0;
 end
end
endmodule
