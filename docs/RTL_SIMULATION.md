# RTL executable simulation

CI now has two executable SystemVerilog tests in addition to lint:

1. `tb_qart_frame_guard.sv` — valid command acceptance plus CRC, sequence and command-bound rejection.
2. `tb_qart_axis_frame_rx.sv` — eight-beat QHAP frame decode and malformed early-TLAST rejection.

These tests exercise RTL in software simulation. They are not FPGA synthesis, timing closure, board-loopback, RF/IQ-loopback or physical-QPU evidence.
