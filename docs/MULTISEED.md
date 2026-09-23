# Multi-seed study

POST /api/multiseed runs matched Baseline/QART simulations across 2–100 deterministic seeds.

Default: 25 seeds × 600 cycles with the same injected fault magnitude per matched pair.

The endpoint reports aggregate means plus per-seed rows. This is a robustness check for the digital twin only, not a hardware benchmark or quantum-advantage claim.
