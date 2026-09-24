#!/usr/bin/env bash
set -euo pipefail

# Device-targeted implementation only. This does not program or verify a board.
export QART_PART="${QART_PART:-xczu28dr-ffvg1517-2-e}"
export QART_TOP="${QART_TOP:-qart_zcu111_top}"

if ! command -v vivado >/dev/null 2>&1; then
  echo "ERROR: Vivado is required for the ZCU111 vendor implementation gate." >&2
  exit 127
fi

vivado -mode batch -nojournal -nolog -source fpga/vivado/build.tcl
