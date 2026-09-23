# QART Experiment API v1

## POST /api/experiment
Runs a deterministic 16-qubit digital-twin experiment.

JSON body:
- `seed`: integer, reproducibility seed
- `cycles`: 1..2000
- `mode`: `baseline` or `qart`
- `fault`: injected drift magnitude, 0..0.02

Response includes experiment ID, mean fidelity, availability, intervention count, telemetry series and final per-qubit fidelity.

Every response includes `claimBoundary: "simulation"`. These values are not physical-QPU measurements.

## GET /api/health
Returns API status and version.
