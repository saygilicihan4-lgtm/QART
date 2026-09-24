module qart_zcu111_top #(
 parameter integer WATCHDOG_CYCLES=32
)(
 input  logic        clk_100_p,
 input  logic        clk_100_n,
 input  logic        qhap_resetn,

 input  logic        arm,
 input  logic        clear_fault,
 input  logic        resync,
 input  logic [31:0] resync_value,

 // Logical PS/host producer boundary. A later PS block design supplies these signals.
 input  logic        host_valid,
 output logic        host_ready,
 input  logic [31:0] host_data,
 input  logic [3:0]  host_keep,
 input  logic        host_last,

 output logic        permit,
 output logic        fault,
 output logic        safe_noop,
 output logic        transport_fault,
 output logic [31:0] expected_seq
);
 logic qhap_clk;

 IBUFDS #(
  .DIFF_TERM("TRUE"),
  .IBUF_LOW_PWR("FALSE")
 ) qhap_clk_ibuf (
  .I(clk_100_p),
  .IB(clk_100_n),
  .O(qhap_clk)
 );

 qart_qhap_host_fpga_top #(.WATCHDOG_CYCLES(WATCHDOG_CYCLES)) core(
  .qhap_clk(qhap_clk),
  .qhap_resetn(qhap_resetn),
  .arm(arm),
  .clear_fault(clear_fault),
  .resync(resync),
  .resync_value(resync_value),
  .host_valid(host_valid),
  .host_ready(host_ready),
  .host_data(host_data),
  .host_keep(host_keep),
  .host_last(host_last),
  .permit(permit),
  .fault(fault),
  .safe_noop(safe_noop),
  .transport_fault(transport_fault),
  .expected_seq(expected_seq)
 );
endmodule
