from hardware.qhap_frame import pack_frame

def write_frame(path: str, seq: int) -> bytes:
    frame = pack_frame(
        kind=1,
        flags=0,
        seq=seq,
        channel=3,
        action=1,
        amp=0x4000,
        duration=100,
        p0=0x11223344,
        p1=0x55667788,
    )
    assert len(frame) == 32
    with open(path, "w") as out:
        for i in range(0, 32, 4):
            # QHAP bytes are little-endian; AXI tdata is the numeric 32-bit word.
            out.write(f"{int.from_bytes(frame[i:i+4], 'little'):08x}\n")
    return frame

f0 = write_frame("tests/qhap_e2e_words.hex", 0)
f1 = write_frame("tests/qhap_e2e_words_seq1.hex", 1)
f3 = write_frame("tests/qhap_e2e_words_seq3.hex", 3)

print("QHAP Python golden frame seq0:", f0.hex())
print("QHAP Python recovery frame seq1:", f1.hex())
print("QHAP Python gap frame seq3:", f3.hex())
