# QART Vivado implementation flow
# PRE-HARDWARE: this script builds a selected FPGA part; it does not imply board verification.

if {![info exists ::env(QART_PART)] || $::env(QART_PART) eq ""} {
  error "QART_PART must name the exact AMD/Xilinx device part before vendor implementation"
}
set part $::env(QART_PART)
set top [expr {[info exists ::env(QART_TOP)] && $::env(QART_TOP) ne "" ? $::env(QART_TOP) : "qart_qhap_fpga_top"}]
set outdir [file normalize "build/vivado"]
file mkdir $outdir

read_verilog -sv [list   rtl/qart_reset_sync.sv   rtl/qart_crc32_ieee.sv   rtl/qart_qhap_crc_stream.sv   rtl/qart_frame_guard.sv   rtl/qart_axis_frame_rx.sv   rtl/qart_sequence_guard.sv   rtl/qart_watchdog.sv   rtl/qart_fail_closed_ingress.sv   rtl/qart_qhap_ingress_top.sv   fpga/rtl/qart_axil_control.sv
 fpga/rtl/qart_qhap_word_bridge.sv   fpga/rtl/qart_qhap_fpga_top.sv   fpga/rtl/qart_qhap_host_fpga_top.sv
 fpga/rtl/qart_qhap_ps_boundary.sv   fpga/rtl/qart_zcu111_top.sv ]
if {$top eq "qart_zcu111_top"} {
  read_xdc fpga/constraints/zcu111_board.xdc
} else {
  read_xdc fpga/constraints/qart_qhap_timing.xdc
}

synth_design -mode out_of_context -top $top -part $part
write_checkpoint -force $outdir/post_synth.dcp
report_utilization -file $outdir/post_synth_utilization.rpt

opt_design
place_design
phys_opt_design
route_design
write_checkpoint -force $outdir/post_route.dcp
report_utilization -file $outdir/post_route_utilization.rpt
report_methodology -file $outdir/methodology.rpt
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose   -max_paths 20 -file $outdir/timing_summary.rpt

set setup_paths [get_timing_paths -delay_type max -max_paths 1 -nworst 1]
if {[llength $setup_paths] == 0} {
  error "No setup timing path found; implementation result is not acceptable"
}
set wns [get_property SLACK [lindex $setup_paths 0]]
puts "QART_WNS_NS=$wns"
if {$wns < 0.0} {
  error "QART timing gate failed: WNS is negative ($wns ns)"
}

set unconstrained [get_timing_paths -unconstrained -max_paths 1]
if {[llength $unconstrained] != 0} {
  error "QART timing gate failed: unconstrained timing path detected"
}

puts "QART_VENDOR_IMPLEMENTATION_PASS part=$part WNS_NS=$wns"
