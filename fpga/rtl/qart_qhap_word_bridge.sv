module qart_qhap_word_bridge(
 input  logic        clk,
 input  logic        rst_n,

 // Host/PS-side write interface. One accepted write is one QHAP 32-bit AXI beat.
 input  logic        host_valid,
 output logic        host_ready,
 input  logic [31:0] host_data,
 input  logic [3:0]  host_keep,
 input  logic        host_last,

 // QHAP AXI-stream side.
 output logic [31:0] m_axis_tdata,
 output logic [3:0]  m_axis_tkeep,
 output logic        m_axis_tvalid,
 input  logic        m_axis_tready,
 output logic        m_axis_tlast,

 output logic        overflow_fault
);
 logic full;

 assign host_ready = !full || (m_axis_tready && m_axis_tvalid);
 assign m_axis_tvalid = full;

 always_ff @(posedge clk) begin
  if(!rst_n) begin
   full<=1'b0;
   m_axis_tdata<=32'd0;
   m_axis_tkeep<=4'd0;
   m_axis_tlast<=1'b0;
   overflow_fault<=1'b0;
  end else begin
   if(host_valid && !host_ready)
    overflow_fault<=1'b1;

   if(host_valid && host_ready) begin
    m_axis_tdata<=host_data;
    m_axis_tkeep<=host_keep;
    m_axis_tlast<=host_last;
    full<=1'b1;
   end else if(m_axis_tready && m_axis_tvalid) begin
    full<=1'b0;
   end
  end
 end
endmodule
