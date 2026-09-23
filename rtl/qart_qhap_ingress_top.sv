module qart_qhap_ingress_top #(parameter integer WATCHDOG_CYCLES=32)(
 input logic clk,input logic rst_n,input logic arm,input logic clear_fault,input logic resync,input logic[31:0]resync_value,
 input logic[31:0]s_axis_tdata,input logic[3:0]s_axis_tkeep,input logic s_axis_tvalid,output logic s_axis_tready,input logic s_axis_tlast,
 output logic permit,output logic fault,output logic safe_noop,output logic[31:0]expected_seq
);
 logic rx_valid,rx_fault; logic[31:0]magic,seq,crc_received,p0,p1; logic[7:0]version,kind; logic[15:0]flags,channel,action,amplitude,duration;
 logic[2:0] beat_count; logic crc_start,crc_feed,frame_pending,rx_valid_latched,rx_fault_latched,crc_ready; logic[31:0]crc_calc,crc_word_latched;
 qart_axis_frame_rx rx(.aclk(clk),.aresetn(rst_n),.s_axis_tdata(s_axis_tdata),.s_axis_tkeep(s_axis_tkeep),.s_axis_tvalid(s_axis_tvalid),.s_axis_tready(s_axis_tready),.s_axis_tlast(s_axis_tlast),.frame_valid(rx_valid),.frame_fault(rx_fault),.magic(magic),.seq(seq),.crc_received(crc_received),.version(version),.kind(kind),.flags(flags),.channel(channel),.action(action),.amplitude(amplitude),.duration(duration),.payload0(p0),.payload1(p1));
 always_ff @(posedge clk) begin
  if(!rst_n) begin beat_count<=0;crc_start<=0;crc_feed<=0;frame_pending<=0;rx_valid_latched<=0;rx_fault_latched<=0;crc_word_latched<=0; end
  else begin
   crc_start<=0; crc_feed<=0;
   if(frame_pending && crc_ready) begin frame_pending<=0; rx_valid_latched<=0; rx_fault_latched<=0; end
   if(s_axis_tvalid&&s_axis_tready) begin
    if(beat_count==0) crc_start<=1;
    if(beat_count<7) crc_feed<=1;
    if(beat_count==7 && s_axis_tlast) begin crc_word_latched<=s_axis_tdata; frame_pending<=1; rx_valid_latched<=1; rx_fault_latched<=0; end
    if(s_axis_tlast||rx_fault) beat_count<=0; else beat_count<=beat_count+1'b1;
   end
  end
 end
 qart_qhap_crc_stream cs(.clk(clk),.rst_n(rst_n),.start(crc_start),.tdata(s_axis_tdata),.beat_valid(crc_feed),.beat_index(beat_count),.crc(crc_calc),.ready(crc_ready));
 qart_fail_closed_ingress #(.WATCHDOG_CYCLES(WATCHDOG_CYCLES)) gate(.clk(clk),.rst_n(rst_n),.arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),.frame_valid(frame_pending && crc_ready),.protocol_ok(rx_valid_latched && !rx_fault_latched),.crc_ok(crc_word_latched==crc_calc),.magic(magic),.version(version),.kind(kind),.seq(seq),.channel(channel),.action(action),.amplitude(amplitude),.duration(duration),.permit(permit),.fault(fault),.safe_noop(safe_noop),.expected_seq(expected_seq));
endmodule
