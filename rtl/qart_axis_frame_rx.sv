module qart_axis_frame_rx(
 input logic aclk,input logic aresetn,
 input logic [31:0] s_axis_tdata,input logic [3:0] s_axis_tkeep,
 input logic s_axis_tvalid,output logic s_axis_tready,input logic s_axis_tlast,
 output logic frame_valid,output logic frame_fault,
 output logic [31:0] magic,seq,crc_received,
 output logic [7:0] version,kind,
 output logic [15:0] flags,channel,action,amplitude,duration,
 output logic [31:0] payload0,payload1
);
 logic [2:0] beat;
 assign s_axis_tready=1'b1;
 always_ff @(posedge aclk) begin
  if(!aresetn) begin beat<=0; frame_valid<=0; frame_fault<=0; end
  else begin frame_valid<=0; frame_fault<=0;
   if(s_axis_tvalid&&s_axis_tready) begin
    if(s_axis_tkeep!=4'hF) begin frame_fault<=1; beat<=0; end
    else case(beat)
      0: begin magic<=s_axis_tdata; beat<=1; end
      1: begin version<=s_axis_tdata[7:0];kind<=s_axis_tdata[15:8];flags<=s_axis_tdata[31:16];beat<=2;end
      2: begin seq<=s_axis_tdata;beat<=3;end
      3: begin channel<=s_axis_tdata[15:0];action<=s_axis_tdata[31:16];beat<=4;end
      4: begin amplitude<=s_axis_tdata[15:0];duration<=s_axis_tdata[31:16];beat<=5;end
      5: begin payload0<=s_axis_tdata;beat<=6;end
      6: begin payload1<=s_axis_tdata;beat<=7;end
      7: begin crc_received<=s_axis_tdata;if(s_axis_tlast)frame_valid<=1;else frame_fault<=1;beat<=0;end
    endcase
    if(s_axis_tlast && beat!=7) begin frame_fault<=1;beat<=0;end
   end
  end
 end
endmodule
