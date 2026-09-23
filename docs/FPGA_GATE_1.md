# FPGA Gate 1

Gate 1 is passed only when CI and later hardware evidence establish:

- Python QHAP frame encoder/decoder accepts valid frames and rejects corrupted frames.
- RTL lints/elaborates without behavior-affecting errors.
- AXI4-Stream receiver preserves the fixed 8-beat / 32-byte frame boundary.
- Safety assertion: permit implies valid header, CRC, monotonic sequence and bounded command.
- Fault implies permit is false.
- No claim of FPGA timing is made from CI simulation.

Next gates: executable RTL testbench -> synthesis -> timing closure -> board loopback -> RF/IQ loopback.
