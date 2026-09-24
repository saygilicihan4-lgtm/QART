# ZCU111 PS/DMA Bring-up

Status: PRE-HARDWARE / NOT BOARD-VERIFIED.

`create_zcu111_ps_dma.tcl` defines the first PS-to-QHAP transport design:

`Zynq UltraScale+ PS DDR -> AXI DMA MM2S -> AXI Clock Converter -> QHAP S_AXIS`

The clock converter is mandatory in this reference design because the QHAP safety core uses the selected `qhap_clk` domain. The design must not assume that PS `pl_clk0` and `qhap_clk` are phase aligned merely because both may be configured near 100 MHz.

The DMA is transmit-only for the first bring-up. Software writes the 32-byte QHAP frame to memory, starts one MM2S transfer, and the stream crosses into the QHAP clock domain. Status/telemetry return transport is intentionally a later gate.

## Physical bring-up acceptance

The first board session must keep RF/pulse outputs disconnected. It passes only if:

- the exact 32-byte Python golden frame advances `expected_seq` from 0 to 1;
- replay leaves `expected_seq` at 1 and does not permit execution;
- malformed frame tests remain fail-closed;
- stopping host traffic causes watchdog safe-NOOP;
- no transport overflow is observed;
- measured latency/jitter are recorded rather than inferred from simulation.

This script requires Vivado with the ZCU111 board/device support installed. CI currently checks the script contract but does not claim to execute licensed Vivado implementation.
