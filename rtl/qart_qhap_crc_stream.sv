module qart_qhap_crc_stream(
 input logic clk,input logic rst_n,input logic start,
 input logic [31:0] tdata,input logic beat_valid,input logic [2:0] beat_index,
 output logic [31:0] crc, output logic ready
);
 integer i,j; logic [31:0] state,next_state;
 function automatic [31:0] crc_byte(input [31:0] s,input [7:0] b);
  reg[31:0] c; integer k; begin c=s^{24'h0,b};for(k=0;k<8;k=k+1)c=c[0]?(c>>1)^32'hEDB88320:(c>>1);crc_byte=c;end
 endfunction
 assign crc=state^32'hFFFFFFFF;
 always_ff @(posedge clk) begin
  if(!rst_n) begin state<=32'hFFFFFFFF;ready<=0;end
  else begin
   ready<=0;
   if(beat_valid && beat_index<7) begin
    next_state = start ? 32'hFFFFFFFF : state;
    next_state=crc_byte(next_state,tdata[7:0]);
    next_state=crc_byte(next_state,tdata[15:8]);
    next_state=crc_byte(next_state,tdata[23:16]);
    next_state=crc_byte(next_state,tdata[31:24]);
    state<=next_state;
    if(beat_index==6) ready<=1;
   end
  end
 end
endmodule
