# QART Hardware Status ABI v0.1

The first physical bring-up exposes two hardware-visible 32-bit values:

- `expected_seq`: next QHAP sequence number accepted by the stateful guard.
- `status_flags`:
  - bit 0: `permit`
  - bit 1: `fault`
  - bit 2: `safe_noop`
  - bit 3: `transport_fault`
  - bit 4: `arm`
  - bits 31:5: reserved, zero

These values are the minimum evidence surface for PS-readable registers or an ILA capture. Software DMA completion is never a substitute for these hardware states.

The ABI is observational. It must not bypass or weaken the existing fail-closed safety path.
