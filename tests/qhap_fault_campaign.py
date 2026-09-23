import random, struct, zlib
from hardware.qhap_frame import pack_frame, unpack_frame
R=random.Random(20260923)
N=10000
accepted=0; rejected=0
for i in range(N):
    seq=i & 0xffffffff
    f=bytearray(pack_frame(1,0,seq,R.randrange(64),R.randrange(3),R.randrange(0x8000),R.randrange(1,0x10000),R.getrandbits(32),R.getrandbits(32)))
    mode=R.randrange(10)
    if mode==0:
        # valid command
        if not unpack_frame(bytes(f))["valid"]: raise SystemExit(f"valid frame rejected at {i}")
        accepted+=1
    else:
        # Deterministic corruptions across header/body/CRC. Any bit mutation without CRC repair must fail CRC/header.
        pos=R.randrange(32); bit=1<<R.randrange(8); f[pos]^=bit
        if unpack_frame(bytes(f))["valid"]:
            # A mutation inside the CRC can theoretically collide only if it exactly preserves CRC; a single-bit change cannot.
            raise SystemExit(f"corrupt frame accepted at {i}, byte={pos}, bit={bit:#x}")
        rejected+=1
print(f"QHAP_FAULT_CAMPAIGN_PASS total={N} valid={accepted} rejected={rejected}")
