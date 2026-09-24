module qart_qhap_word_bridge(
 input logic clk,input logic rst_n,input logic clear_fault,
 input logic host_valid,output logic host_ready,input logic [31:0] host_data,input logic [3:0] host_keep,input logic host_last,
 output logic [31:0] m_axis_tdata,output logic [3:0] m_axis_tkeep,output logic m_axis_tvalid,input logic m_axis_tready,output logic m_axis_tlast,
 output logic overflow_fault
);
 logic full,stall_active;
 logic [31:0] stall_data; logic [3:0] stall_keep; logic stall_last;
 logic violation;
 assign host_ready=!full || (m_axis_tready && m_axis_tvalid);
 assign m_axis_tvalid=full;
 always_comb begin
  violation=1'b0;
  if(stall_active) begin
   if(!host_valid) violation=1'b1;
   else if(host_data!=stall_data || host_keep!=stall_keep || host_last!=stall_last) violation=1'b1;
  end
 end
 always_ff @(posedge clk) begin
  if(!rst_n) begin
   full<=0;m_axis_tdata<=0;m_axis_tkeep<=0;m_axis_tlast<=0;overflow_fault<=0;
   stall_active<=0;stall_data<=0;stall_keep<=0;stall_last<=0;
  end else begin
   if(clear_fault) overflow_fault<=0;
   if(violation) overflow_fault<=1; // violation wins over simultaneous clear

   // AXI backpressure is legal. Snapshot the first stalled beat and require
   // TVALID plus payload/control to remain stable until the handshake.
   if(!stall_active && host_valid && !host_ready) begin
    stall_active<=1;stall_data<=host_data;stall_keep<=host_keep;stall_last<=host_last;
   end else if(stall_active && host_valid && host_ready) begin
    stall_active<=0;
   end

   if(host_valid && host_ready) begin
    m_axis_tdata<=host_data;m_axis_tkeep<=host_keep;m_axis_tlast<=host_last;full<=1;
   end else if(m_axis_tready && m_axis_tvalid) full<=0;
  end
 end
endmodule
