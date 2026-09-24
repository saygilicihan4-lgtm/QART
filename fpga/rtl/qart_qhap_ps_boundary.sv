module qart_qhap_ps_boundary #(
 parameter integer WATCHDOG_CYCLES=32
)(
 input logic qhap_clk,input logic qhap_resetn,
 input logic [31:0] s_axis_tdata,input logic [3:0] s_axis_tkeep,
 input logic s_axis_tvalid,output logic s_axis_tready,input logic s_axis_tlast,
 input logic [5:0] s_axil_awaddr,input logic s_axil_awvalid,output logic s_axil_awready,
 input logic [31:0] s_axil_wdata,input logic [3:0] s_axil_wstrb,input logic s_axil_wvalid,output logic s_axil_wready,
 output logic [1:0] s_axil_bresp,output logic s_axil_bvalid,input logic s_axil_bready,
 input logic [5:0] s_axil_araddr,input logic s_axil_arvalid,output logic s_axil_arready,
 output logic [31:0] s_axil_rdata,output logic [1:0] s_axil_rresp,output logic s_axil_rvalid,input logic s_axil_rready,
 output logic permit,output logic fault,output logic safe_noop,output logic transport_fault
);
 logic arm,clear_fault,resync;
 logic [31:0] resync_value,expected_seq,status_flags;

 qart_axil_control ctrl(
  .aclk(qhap_clk),.aresetn(qhap_resetn),
  .s_axil_awaddr(s_axil_awaddr),.s_axil_awvalid(s_axil_awvalid),.s_axil_awready(s_axil_awready),
  .s_axil_wdata(s_axil_wdata),.s_axil_wstrb(s_axil_wstrb),.s_axil_wvalid(s_axil_wvalid),.s_axil_wready(s_axil_wready),
  .s_axil_bresp(s_axil_bresp),.s_axil_bvalid(s_axil_bvalid),.s_axil_bready(s_axil_bready),
  .s_axil_araddr(s_axil_araddr),.s_axil_arvalid(s_axil_arvalid),.s_axil_arready(s_axil_arready),
  .s_axil_rdata(s_axil_rdata),.s_axil_rresp(s_axil_rresp),.s_axil_rvalid(s_axil_rvalid),.s_axil_rready(s_axil_rready),
  .arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),
  .status_flags(status_flags),.expected_seq(expected_seq)
 );

 qart_qhap_host_fpga_top #(.WATCHDOG_CYCLES(WATCHDOG_CYCLES)) core(
  .qhap_clk(qhap_clk),.qhap_resetn(qhap_resetn),
  .arm(arm),.clear_fault(clear_fault),.resync(resync),.resync_value(resync_value),
  .host_valid(s_axis_tvalid),.host_ready(s_axis_tready),.host_data(s_axis_tdata),.host_keep(s_axis_tkeep),.host_last(s_axis_tlast),
  .permit(permit),.fault(fault),.safe_noop(safe_noop),.transport_fault(transport_fault),
  .expected_seq(expected_seq),.status_flags(status_flags)
 );
endmodule
