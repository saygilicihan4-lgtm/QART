# QART FPGA Implementation Target

Status: PRE-HARDWARE / NOT BOARD-VERIFIED.

This directory defines the vendor implementation boundary for the QHAP autonomous ingress RTL.

## Reference target

The first implementation profile targets the AMD/Xilinx Zynq UltraScale+ RFSoC family because QART's planned physical chain requires deterministic FPGA logic next to high-speed DAC/ADC resources. No specific board or device is claimed as tested until a physical target is selected and measured.

## Clock profile

- QHAP AXI ingress reference clock: 100 MHz (10 ns)
- Clock name: qhap_clk
- Reset: synchronous design logic driven from an externally synchronized active-low reset
- Initial timing objective: WNS >= 0 ns at 100 MHz
- This is an implementation objective, not a measured hardware result.

## Required implementation gates

1. Vendor synthesis completes with no unconstrained internal clock.
2. Implementation/route completes.
3. Timing summary reports WNS >= 0 ns and no failing setup/hold paths.
4. CDC/reset review passes for the selected board wrapper.
5. AXI loopback reproduces the Python QHAP golden frame.
6. Watchdog host-loss test forces safe NOOP on the physical FPGA.
7. Fault injection remains fail-closed on the physical FPGA.
8. Latency and jitter are measured on hardware before any deterministic-latency claim.

See `constraints/qart_qhap_timing.xdc` for the initial clock constraint.
