module qart_qhap_fpga_top #(
 parameter integer WATCHDOG_CYCLES=32
)(
 input  logic        qhap_clk,
 input  logic        qhap_resetn,

 // Control inputs are required to be synchronous to qhap_clk at this boundary.
 input  logic        arm,
 input  logic        clear_fault,
 input  logic        resync,
 input  logic [31:0] resync_value,

 input  logic [31:0] s_axis_tdata,
 input  logic [3:0]  s_axis_tkeep,
 input  logic        s_axis_tvalid,
 output logic        s_axis_tready,
 input  logic        s_axis_tlast,

 output logic        permit,
 output logic        fault,
 output logic        safe_noop,
 output logic [31:0] expected_seq
);
 logic rst_n_sync;

 qart_reset_sync reset_sync(
  .clk(qhap_clk),
  .arst_n(qhap_resetn),
  .srst_n(rst_n_sync)
 );

 qart_qhap_ingress_top #(.WATCHDOG_CYCLES(WATCHDOG_CYCLES)) ingress(
  .clk(qhap_clk),
  .rst_n(rst_n_sync),
  .arm(arm),
  .clear_fault(clear_fault),
  .resync(resync),
  .resync_value(resync_value),
  .s_axis_tdata(s_axis_tdata),
  .s_axis_tkeep(s_axis_tkeep),
  .s_axis_tvalid(s_axis_tvalid),
  .s_axis_tready(s_axis_tready),
  .s_axis_tlast(s_axis_tlast),
  .permit(permit),
  .fault(fault),
  .safe_noop(safe_noop),
  .expected_seq(expected_seq)
 );
endmodule
