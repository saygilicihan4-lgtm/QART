# ZCU111 Host Transport Contract

Status: PRE-HARDWARE / NOT BOARD-VERIFIED.

The selected host transport boundary is AXI4-Stream. The ZCU111 wrapper exposes a Vivado-recognizable `S_AXIS` interface so a later Zynq PS block design can feed QHAP through AXI DMA or equivalent stream infrastructure without changing the safety core.

## Transfer contract

A QHAP frame is exactly eight accepted 32-bit beats:

- `TDATA`: Python-generated little-endian 32-bit QHAP word
- `TKEEP`: `4'hF` on every beat
- `TLAST`: asserted only on beat 7
- `TVALID/TREADY`: normal AXI4-Stream backpressure contract

The one-word bridge can accept a new word while the previous word is consumed. A producer that violates backpressure causes a sticky transport fault, and the integrated FPGA boundary ORs that fault into global `fault` and `safe_noop`.

## Intended PS path

The intended first bring-up path is:

`Linux/PS memory -> AXI DMA/stream producer -> ZCU111 S_AXIS -> QHAP bridge -> CRC/protocol guard -> sequence guard -> watchdog -> permit/safe-NOOP`

The PS/DMA block design is not yet physically built or measured. The AXI interface annotations only establish the synthesizable integration boundary.

## Bring-up sequence

1. Keep physical pulse execution disconnected.
2. Send the Python golden QHAP frame through the PS/PL stream path.
3. Require expected sequence to advance exactly once.
4. Replay the same frame and require rejection.
5. Inject bad `TKEEP`, early/missing `TLAST`, CRC corruption and sequence gaps.
6. Stop host traffic and require watchdog safe-NOOP.
7. Measure host-to-PL latency and jitter.
8. Only after those gates pass, connect DAC/ADC or I/Q loopback.

No deterministic-latency or hardware-verified claim is permitted before the physical measurements.
