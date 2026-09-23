module qart_sequence_guard(
 input logic clk,input logic rst_n,input logic accept,input logic resync,
 input logic [31:0] seq,input logic [31:0] resync_value,
 output logic [31:0] expected_seq,output logic seq_ok
);
assign seq_ok=(seq==expected_seq);
always_ff @(posedge clk) begin
 if(!rst_n) expected_seq<=32'd0;
 else if(resync) expected_seq<=resync_value;
 else if(accept && seq_ok) expected_seq<=expected_seq+32'd1;
end
endmodule
