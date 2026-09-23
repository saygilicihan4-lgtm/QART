from hardware.qhap_frame import pack_frame
f=pack_frame(kind=1,flags=0,seq=7,channel=3,action=1,amp=0x4000,duration=100,p0=0x11223344,p1=0x55667788)
assert len(f)==32
with open("tests/qhap_e2e_words.hex","w") as out:
    for i in range(0,32,4):
        out.write(f[i:i+4].hex()+"\n")
print("QHAP Python golden frame:",f.hex())
