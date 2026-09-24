# ZCU111 Host Transport Contract

Status: PRE-HARDWARE / NOT BOARD-VERIFIED.

The first host transport boundary is intentionally split into two layers:

1. **Host/PS producer** supplies one 32-bit QHAP word plus `keep`, `last`, and `valid`.
2. **QHAP word bridge** converts that producer handshake into the existing AXI-stream ingress contract.

This keeps QHAP safety logic independent from Linux, DMA, PCIe, Ethernet, or a specific Zynq PS software stack.

## Transfer contract

A QHAP frame is exactly eight accepted 32-bit beats. The host must preserve the Python-generated little-endian word order and assert `host_last` only on beat 7. `host_keep` must be `4'hF` for every beat.

The bridge has a one-word elastic register. It may accept a new word on the same cycle that the previous word is consumed. If a producer violates backpressure by asserting a write while the bridge is unable to accept it, `overflow_fault` becomes sticky. The board integration layer must OR that condition into the fail-closed fault/safe-NOOP path before physical execution is enabled.

## Next physical layer

The selected ZCU111 implementation should connect this logical producer to a PS-accessible transport (for example AXI DMA/AXI Stream infrastructure). That integration is not yet claimed as built or measured.

Before enabling physical pulse execution:

- replay the Python golden QHAP frame through the PS/PL path;
- verify CRC and expected-sequence advancement;
- inject malformed keep/TLAST, replay, CRC corruption and host loss;
- require safe NOOP on every rejected case;
- measure end-to-end host-to-PL latency and jitter.
