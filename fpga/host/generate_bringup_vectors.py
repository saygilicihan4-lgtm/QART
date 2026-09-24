#!/usr/bin/env python3
"""Generate deterministic QHAP board bring-up/fault-injection payloads.

No hardware access is performed. These files are the exact DMA payload corpus
used during the first physical ZCU111 session.
"""
import json
from pathlib import Path
from hardware.qhap_frame import pack_frame, unpack_frame

OUT=Path("build/bringup_vectors")

def valid(seq:int)->bytes:
    return pack_frame(1,0,seq,3,1,0x4000,100,0x11223344,0x55667788)

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    v0=valid(0)
    replay=v0
    gap=valid(3)

    crc=bytearray(v0); crc[20]^=0x01
    magic=bytearray(v0); magic[0]^=0x01

    cases=[
      ("valid_seq0",v0,True,"expected_seq advances 0->1"),
      ("replay_seq0",replay,True,"rejected by sequence guard; expected_seq remains 1"),
      ("gap_seq3",gap,True,"rejected by sequence guard; expected_seq remains 1"),
      ("crc_corrupt",bytes(crc),False,"CRC reject; fail-closed"),
      ("magic_corrupt",bytes(magic),False,"header/CRC reject; fail-closed"),
    ]
    manifest=[]
    for name,data,protocol_valid,expect in cases:
        path=OUT/f"{name}.bin"; path.write_bytes(data)
        decoded=unpack_frame(data)
        if protocol_valid and not decoded.get("valid"):
            raise SystemExit(f"{name}: unexpectedly invalid protocol frame")
        if not protocol_valid and decoded.get("valid"):
            raise SystemExit(f"{name}: mutation unexpectedly valid")
        manifest.append({
          "name":name,"file":str(path),"bytes":len(data),
          "protocol_valid":bool(decoded.get("valid")),"expected_hardware_result":expect
        })
    (OUT/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
    print("QART_BRINGUP_VECTOR_CORPUS_PASS cases=5 bytes_each=32")

if __name__=="__main__":
    main()
