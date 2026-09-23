# QHAP Binary Frame v0.2

Transport-neutral 32-byte command/telemetry envelope for the FPGA boundary.

All multi-byte fields are little-endian.

| Offset | Size | Field |
|---|---:|---|
| 0 | 4 | Magic = 0x51484150 ("QHAP") |
| 4 | 1 | Version = 2 |
| 5 | 1 | Type: 1 command, 2 telemetry, 3 ack, 4 fault |
| 6 | 2 | Flags |
| 8 | 4 | Sequence |
| 12 | 2 | Channel |
| 14 | 2 | Action |
| 16 | 2 | Amplitude Q1.15 |
| 18 | 2 | Duration ticks |
| 20 | 4 | Payload/telemetry word 0 |
| 24 | 4 | Payload/telemetry word 1 |
| 28 | 4 | CRC-32/IEEE over bytes 0..27 |

Receiver invariants: correct magic/version/type, CRC, monotonic sequence, bounded channel/action/amplitude/duration. Any violation produces NOOP + FAULT and never reaches the pulse sequencer.

The frame can later be carried over AXI4-Stream; transport handshake and framing are separate from QHAP semantics.
