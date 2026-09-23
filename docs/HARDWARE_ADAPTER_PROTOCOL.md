# QART Hardware Adapter Protocol (QHAP) v0.1

QHAP keeps the web/research layer independent from the execution backend.

## Backends
- `simulator` — current deterministic digital twin
- `fpga` — future verified FPGA/RFSoC adapter
- `qpu` — future laboratory device adapter; disabled until physical validation

## Request envelope
```json
{
  "protocol":"QHAP/0.1",
  "requestId":"...",
  "backend":"simulator",
  "operation":"experiment",
  "seed":42,
  "cycles":600,
  "fault":0.007
}
```

## Response envelope
Every response MUST declare provenance:
```json
{
  "protocol":"QHAP/0.1",
  "backend":"simulator",
  "measurementClass":"simulation",
  "hardwareVerified":false,
  "result":{}
}
```

## Safety invariants
1. Learned/AI policy never bypasses the deterministic Safety Gate.
2. Unknown backend, operation, parameter or action fails closed.
3. FPGA/QPU adapters must expose watchdog state and sequence integrity.
4. Simulation data must never be labeled hardware measurement.
5. Physical output commands require bounded amplitude, duration, repetition and channel IDs.
6. Backend provenance is mandatory and immutable in the returned report.

QHAP is an interface specification, not evidence that an FPGA or QPU is connected.
