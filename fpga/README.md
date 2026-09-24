# QART FPGA Implementation Target

Status: PRE-HARDWARE / NOT BOARD-VERIFIED.

This directory defines the vendor implementation boundary for the QHAP autonomous ingress RTL.

## Selected reference target

The first concrete device target is the AMD/Xilinx ZCU111 Evaluation Board profile:

- Device: XCZU28DR
- Vivado part: `xczu28dr-ffvg1517-2-e`
- Board part profile: `xilinx.com:zcu111:part0:1.4`
- Reference PL clock: ZCU111 `CLK_100`, 100 MHz
- Target manifest: `targets/zcu111.json`

The target selection is for synthesis/implementation planning. It does not mean a ZCU111 board has been programmed or measured.

## Clock profile

- QHAP AXI ingress reference clock: 100 MHz (10 ns)
- Logical clock name: `qhap_clk`
- Reset boundary: asynchronous assert / synchronous release through `qart_reset_sync`
- Initial timing objective: WNS >= 0 ns at 100 MHz
- The Vivado flow is out-of-context/device-targeted until a board integration wrapper and physical interfaces are connected.

## Verification layers

Current automated gates cover protocol vectors, fail-closed RTL simulation, one-million-case frame-guard fault injection, Verilator lint/regressions, generic Yosys synthesis, UltraScale+ technology mapping, and the vendor-flow contract.

A real hardware claim requires the later physical gates below.

## Required physical implementation gates

1. Vendor synthesis and route complete for the selected part.
2. Timing summary reports WNS >= 0 ns with no unexplained unconstrained paths.
3. Board wrapper and CDC/reset review pass.
4. AXI/transport loopback reproduces the Python QHAP golden frame on physical hardware.
5. Watchdog host-loss forces safe NOOP on the physical FPGA.
6. Fault injection remains fail-closed on the physical FPGA.
7. DAC/ADC or I/Q loopback is measured before attaching a cryogenic device.
8. End-to-end latency and jitter are measured before any deterministic-latency claim.

Run `fpga/vivado/build_zcu111.sh` on a machine with Vivado installed for the device-targeted vendor implementation gate.
