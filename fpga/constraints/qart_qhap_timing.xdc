# QART QHAP reference timing constraints
# PRE-HARDWARE: reference constraint only; board pin/IO constraints are intentionally absent.
#
# The board wrapper must expose a clock port named qhap_clk.
create_clock -name qhap_clk -period 10.000 [get_ports qhap_clk]

# Do not add false paths or multicycle exceptions here without a documented hardware reason.
# Board-specific reset synchronizer and I/O delays belong in the selected target wrapper constraints.
