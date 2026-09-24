module qart_qhap_ingress_top #(parameter integer WATCHDOG_CYCLES=32)(
 input logic clk,input logic rst_n,input logic arm,input logic clear_fault,input logic resync,input logic[31:0]resync_value,
 input logic[31:0]s_axis_tdata,input logic[3:0]s_axis_tkeep,input logic s_axis_tvalid,output logic s_axis_tready,input logic s_axis_tlast,
 output logic permit,output logic fault,output logic safe_noop,output logic[31:0]expected_seq
);
 logic rx_valid,rx_fault;
 logic[31:0]magic,seq,crc_received,p0,p1;
 logic[7:0]version,kind;
 logic[15:0]flags,channel,action,amplitude,duration;
 logic[2:0]beat_count,crc_index_latched;
 logic crc_start,crc_feed,frame_pending,rx_valid_latched,crc_ready,crc_done_latched,protocol_fault_latched;
 logic gate_permit,gate_fault,gate_safe_noop;
 logic[31:0]crc_calc,crc_word_latched,crc_data_latched;

 qart_axis_frame_rx rx(
  .aclk(clk),.aresetn(rst_n),.s_axis_tdata(s_axis_tdata),.s_axis_tkeep(s_axis_tkeep),
  .s_axis_tvalid(s_axis_tvalid),.s_axis_tready(s_axis_tready),.s_axis_tlast(s_axis_tlast),
  .frame_valid(rx_valid),.frame_fault(rx_fault),.magic(magic),.seq(seq),.crc_received(crc_received),
  .version(version),.kind(kind),.flags(flags),.channel(channel),.action(action),
  .amplitude(amplitude),.duration(duration),.payload0(p0),.payload1(p1)
 );

 always_ff @(posedge clk) begin
  if(!rst_n) begin
   beat_count<=0;
   crc_start<=0;
   crc_feed<=0;
   frame_pending<=0;
   rx_valid_latched<=0;
   crc_done_latched<=0;
   protocol_fault_latched<=0;
   crc_word_latched<=0;
   crc_data_latched<=0;
   crc_index_latched<=0;
  end else begin
   crc_start<=0;
   crc_feed<=0;

   if(clear_fault)
    protocol_fault_latched<=0;

   if(crc_ready)
    crc_done_latched<=1;

   if(rx_valid)
    rx_valid_latched<=1;

   if(rx_fault) begin
    protocol_fault_latched<=1;
    beat_count<=0;
    frame_pending<=0;
    rx_valid_latched<=0;
    crc_done_latched<=0;
   end

   if(frame_pending && crc_done_latched && rx_valid_latched) begin
    frame_pending<=0;
    rx_valid_latched<=0;
    crc_done_latched<=0;
   end

   if(s_axis_tvalid && s_axis_tready) begin
    if((s_axis_tkeep!=4'hF) ||
       (s_axis_tlast && beat_count!=3'd7) ||
       ((beat_count==3'd7) && !s_axis_tlast)) begin
     protocol_fault_latched<=1;
     beat_count<=0;
     frame_pending<=0;
     rx_valid_latched<=0;
     crc_done_latched<=0;
    end else begin
     if(beat_count==0) begin
      crc_start<=1;
      crc_done_latched<=0;
     end
     if(beat_count<7) begin
      crc_feed<=1;
      crc_data_latched<=s_axis_tdata;
      crc_index_latched<=beat_count;
     end
     if(beat_count==7) begin
      crc_word_latched<=s_axis_tdata;
      frame_pending<=1;
      beat_count<=0;
     end else begin
      beat_count<=beat_count+1'b1;
     end
    end
   end
  end
 end

 qart_qhap_crc_stream cs(
  .clk(clk),.rst_n(rst_n),.start(crc_start),.tdata(crc_data_latched),
  .beat_valid(crc_feed),.beat_index(crc_index_latched),.crc(crc_calc),.ready(crc_ready)
 );

 qart_fail_closed_ingress #(.WATCHDOG_CYCLES(WATCHDOG_CYCLES)) gate(
  .clk(clk),.rst_n(rst_n),.arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),
  .frame_valid(frame_pending && crc_done_latched && rx_valid_latched && !protocol_fault_latched),
  .protocol_ok(rx_valid_latched && !protocol_fault_latched),
  .crc_ok(crc_word_latched==crc_calc),
  .magic(magic),.version(version),.kind(kind),.seq(seq),.channel(channel),.action(action),
  .amplitude(amplitude),.duration(duration),
  .permit(gate_permit),.fault(gate_fault),.safe_noop(gate_safe_noop),.expected_seq(expected_seq)
 );

 assign permit=gate_permit && !protocol_fault_latched;
 assign fault=gate_fault || protocol_fault_latched;
 assign safe_noop=gate_safe_noop || protocol_fault_latched;
endmodule
