import json,random,sys
sys.path.insert(0,"hardware")
from qhap_frame import pack_frame,unpack_frame
r=random.Random(20260923); rows=[]
for i in range(10000):
    seq=i+1; ch=r.randrange(64); action=r.randrange(3); amp=r.randrange(0x8000); dur=r.randrange(1,65536)
    f=pack_frame(1,0,seq,ch,action,amp,dur,r.getrandbits(32),r.getrandbits(32))
    assert unpack_frame(f)["valid"]
    bad=bytearray(f); bad[r.randrange(28)]^=1
    assert not unpack_frame(bytes(bad))["valid"]
    if i<32: rows.append({"seq":seq,"hex":f.hex()})
open("tests/qhap_golden_vectors.json","w").write(json.dumps(rows,indent=2))
print("10000 valid frames + 10000 corrupted frames checked; 32 golden vectors written")
