# QART ZCU111 board constraints
# PRE-HARDWARE: pin mapping is the selected board profile; no board has been programmed or measured.

set_property PACKAGE_PIN AM15 [get_ports clk_100_p]
set_property PACKAGE_PIN AN15 [get_ports clk_100_n]
set_property IOSTANDARD LVDS [get_ports {clk_100_p clk_100_n}]
set_property DIFF_TERM TRUE [get_ports {clk_100_p clk_100_n}]
create_clock -name qhap_clk -period 10.000 [get_ports clk_100_p]

# Deliberately no physical pin assignments for QHAP AXI/control ports yet.
# They are logical integration ports until the transport (PS/AXI, PCIe or other) is selected.
