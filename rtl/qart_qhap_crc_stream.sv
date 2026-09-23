module qart_qhap_crc_stream(
 input logic clk,input logic rst_n,input logic start,
 input logic [31:0] tdata,input logic beat_valid,input logic [2:0] beat_index,
 output logic [31:0] crc
);
 logic init,bvalid; logic [7:0] bdata; logic [1:0] lane; logic busy; logic [31:0] word;
 qart_crc32_ieee u(.clk(clk),.rst_n(rst_n),.init(init),.valid(bvalid),.data(bdata),.crc(crc));
 always_ff @(posedge clk) begin
  init<=1'b0;bvalid<=1'b0;
  if(start) begin init<=1'b1;busy<=1'b0;lane<=0;end
  else if(beat_valid && beat_index<7 && !busy) begin word<=tdata;lane<=0;busy<=1'b1;end
  else if(busy) begin
   bvalid<=1'b1;
   case(lane) 0:bdata<=word[7:0];1:bdata<=word[15:8];2:bdata<=word[23:16];3:bdata<=word[31:24];endcase
   if(lane==3) busy<=1'b0; else lane<=lane+1'b1;
  end
 end
endmodule
