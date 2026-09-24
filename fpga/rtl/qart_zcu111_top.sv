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

 // AXI4-Stream command ingress. Intended source: Zynq PS via AXI DMA/stream infrastructure.
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TDATA" *)
 (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXIS, TDATA_NUM_BYTES 4, HAS_TKEEP 1, HAS_TLAST 1" *)
 input  logic [31:0] s_axis_tdata,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TKEEP" *)
 input  logic [3:0]  s_axis_tkeep,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TVALID" *)
 input  logic        s_axis_tvalid,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TREADY" *)
 output logic        s_axis_tready,
 (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS TLAST" *)
 input  logic        s_axis_tlast,

 output logic        permit,
 output logic        fault,
 output logic        safe_noop,
 output logic        transport_fault,
 output logic [31:0] expected_seq,
 output logic [31:0] status_flags
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
  .host_valid(s_axis_tvalid),
  .host_ready(s_axis_tready),
  .host_data(s_axis_tdata),
  .host_keep(s_axis_tkeep),
  .host_last(s_axis_tlast),
  .permit(permit),
  .fault(fault),
  .safe_noop(safe_noop),
  .transport_fault(transport_fault),
  .expected_seq(expected_seq),
  .status_flags(status_flags)
 );
endmodule
