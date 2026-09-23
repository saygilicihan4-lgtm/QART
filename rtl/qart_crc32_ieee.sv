module qart_crc32_ieee(input logic clk,input logic rst_n,input logic init,input logic valid,input logic [7:0] data,output logic [31:0] crc);
integer i; logic [31:0] c;
always_ff @(posedge clk) begin
 if(!rst_n||init) crc<=32'hFFFFFFFF;
 else if(valid) begin
   c=crc^data;
   for(i=0;i<8;i=i+1) c=c[0]?(c>>1)^32'hEDB88320:(c>>1);
   crc<=c;
 end
end
endmodule
