# QART ZCU111 Physical Bring-up Runbook

Status: PRE-HARDWARE. This runbook is intentionally fail-closed.

## Before power-on testing

RF/DAC/pulse outputs remain disconnected from any cryogenic device. The first session validates only the digital PS/PL safety path.

Generate the deterministic corpus with:

`PYTHONPATH=. python fpga/host/generate_bringup_vectors.py`

The corpus contains five 32-byte DMA payloads: valid sequence 0, replay sequence 0, valid-CRC sequence gap 3, payload corruption with stale CRC, and corrupted magic/header.

## Required observation path

Before a physical test is considered valid, the PS must be able to observe at least:

- `expected_seq`
- `permit`
- `fault`
- `safe_noop`
- `transport_fault`

Do not infer these states from software success alone. They must be read from a hardware-visible status path or captured by an on-chip logic analyzer.

## Acceptance order

1. Reset and explicitly clear faults; expected sequence must be 0.
2. Send `valid_seq0.bin`; expected sequence must become 1.
3. Send `replay_seq0.bin`; sequence must remain 1 and execution must not be permitted.
4. Send `gap_seq3.bin`; sequence must remain 1 and execution must not be permitted.
5. Send `crc_corrupt.bin`; require fault + safe-NOOP.
6. Clear fault explicitly.
7. Send `magic_corrupt.bin`; require fault + safe-NOOP.
8. Stop host traffic while armed; watchdog must force safe-NOOP.
9. Record latency/jitter measurements and raw evidence.

A software DMA completion by itself is not a QART hardware pass.
