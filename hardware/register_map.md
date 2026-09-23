# QART FPGA register map v0.1

Proposed AXI4-Lite control/status map. Not yet synthesized.

| Offset | Register | Access |
|---|---|---|
| 0x00 | ID = 0x51415254 ("QART") | RO |
| 0x04 | VERSION = 0x00010000 | RO |
| 0x08 | CONTROL: bit0 enable, bit1 soft-reset | RW |
| 0x0C | STATUS: bit0 ready, bit1 fault, bit2 watchdog | RO |
| 0x10 | LAST_RX_SEQ | RO |
| 0x14 | LAST_TX_SEQ | RO |
| 0x18 | FAULT_CODE | RO |
| 0x1C | FAULT_COUNT | RO |
| 0x20 | MAX_CHANNEL | RW bounded <=63 |
| 0x24 | MAX_AMPLITUDE_Q15 | RW bounded <=0x7FFF |
| 0x28 | MAX_DURATION_TICKS | RW |
| 0x2C | WATCHDOG_TICKS | RW |
| 0x30 | CRC_ERROR_COUNT | RO |
| 0x34 | SEQ_ERROR_COUNT | RO |
| 0x38 | SAFETY_REJECT_COUNT | RO |

Configuration writes must themselves pass a bounded configuration gate.
