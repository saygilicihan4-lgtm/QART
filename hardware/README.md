# Hardware boundary

This directory defines the software-facing boundary for future FPGA/RFSoC integration.

Current state: **no physical FPGA/QPU connection is claimed**.

Before enabling `FPGAAdapter.execute`:
1. RTL lint/elaboration passes.
2. Golden-model equivalence has zero unexplained mismatches.
3. Fault injection passes fail-closed invariants.
4. FPGA synthesis/timing is recorded.
5. Board loopback is measured.
6. RF I/Q loopback is measured within bounded envelopes.

Only then may the adapter report `hardwareVerified: true`.
