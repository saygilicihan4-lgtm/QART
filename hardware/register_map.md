# QART FPGA register map v0.2

Implemented AXI4-Lite control/status ABI for first ZCU111 PS bring-up.

| Offset | Register | Access | Meaning |
|---|---|---|---|
| 0x00 | ID | RO | `0x51415254` ("QART") |
| 0x04 | VERSION | RO | `0x00020000` |
| 0x08 | CONTROL | RW/W1P | bit0 `arm`; bit1 `clear_fault` one-cycle pulse; bit2 `resync` one-cycle pulse |
| 0x0C | STATUS | RO | hardware `status_flags` ABI |
| 0x10 | EXPECTED_SEQ | RO | next sequence accepted by QHAP sequence guard |
| 0x14 | RESYNC_VALUE | RW | sequence loaded when CONTROL.resync is pulsed |

Unmapped reads/writes return AXI `SLVERR`. Byte write strobes are honored. `arm` is persistent; `clear_fault` and `resync` are pulses and cannot remain asserted from software.

This v0.2 map replaces the earlier proposed-only v0.1 map. It does not expose arbitrary pulse parameters; physical command parameters remain inside validated QHAP frames.
