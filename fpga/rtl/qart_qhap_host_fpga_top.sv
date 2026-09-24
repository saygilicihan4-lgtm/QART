module qart_qhap_host_fpga_top #(
 parameter integer WATCHDOG_CYCLES=32
)(
 input  logic        qhap_clk,
 input  logic        qhap_resetn,

 input  logic        arm,
 input  logic        clear_fault,
 input  logic        resync,
 input  logic [31:0] resync_value,

 input  logic        host_valid,
 output logic        host_ready,
 input  logic [31:0] host_data,
 input  logic [3:0]  host_keep,
 input  logic        host_last,

 output logic        permit,
 output logic        fault,
 output logic        safe_noop,
 output logic        transport_fault,
 output logic [31:0] expected_seq,
 output logic [31:0] status_flags
);
 logic rst_n_sync;
 logic [31:0] axis_data;
 logic [3:0]  axis_keep;
 logic axis_valid,axis_ready,axis_last;
 logic core_permit,core_fault,core_safe_noop;

 qart_reset_sync reset_sync(
  .clk(qhap_clk),
  .arst_n(qhap_resetn),
  .srst_n(rst_n_sync)
 );

 qart_qhap_word_bridge bridge(
  .clk(qhap_clk),
  .rst_n(rst_n_sync),
  .clear_fault(clear_fault),
  .host_valid(host_valid),
  .host_ready(host_ready),
  .host_data(host_data),
  .host_keep(host_keep),
  .host_last(host_last),
  .m_axis_tdata(axis_data),
  .m_axis_tkeep(axis_keep),
  .m_axis_tvalid(axis_valid),
  .m_axis_tready(axis_ready),
  .m_axis_tlast(axis_last),
  .overflow_fault(transport_fault)
 );

 qart_qhap_ingress_top #(.WATCHDOG_CYCLES(WATCHDOG_CYCLES)) ingress(
  .clk(qhap_clk),
  .rst_n(rst_n_sync),
  .arm(arm),
  .clear_fault(clear_fault),
  .resync(resync),
  .resync_value(resync_value),
  .s_axis_tdata(axis_data),
  .s_axis_tkeep(axis_keep),
  .s_axis_tvalid(axis_valid),
  .s_axis_tready(axis_ready),
  .s_axis_tlast(axis_last),
  .permit(core_permit),
  .fault(core_fault),
  .safe_noop(core_safe_noop),
  .expected_seq(expected_seq)
 );

 // Transport violations are part of the same fail-closed execution boundary.
 assign permit = core_permit && !transport_fault;
 assign fault = core_fault || transport_fault;
 assign safe_noop = core_safe_noop || transport_fault;

 // Stable PS/ILA status ABI: bit0 permit, bit1 fault, bit2 safe_noop,
 // bit3 transport_fault, bit4 armed. Remaining bits reserved zero.
 assign status_flags = {27'd0, arm, transport_fault, safe_noop, fault, permit};
endmodule
