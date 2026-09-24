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
 logic qhap_clk;

 // ZCU111 CLK_100 differential board clock.
 IBUFDS #(
  .DIFF_TERM("TRUE"),
  .IBUF_LOW_PWR("FALSE")
 ) qhap_clk_ibuf (
  .I(clk_100_p),
  .IB(clk_100_n),
  .O(qhap_clk)
 );

 qart_qhap_fpga_top #(.WATCHDOG_CYCLES(WATCHDOG_CYCLES)) core(
  .qhap_clk(qhap_clk),
  .qhap_resetn(qhap_resetn),
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
