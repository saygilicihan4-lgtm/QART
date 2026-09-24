#!/usr/bin/env python3
"""Prepare a canonical 32-byte QHAP command payload for PS/DMA bring-up.

This tool does not access hardware. It creates/validates the exact binary that a
board-side DMA program must transmit.
"""
import argparse
from pathlib import Path
from hardware.qhap_frame import pack_frame, unpack_frame

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument("--sequence",type=int,default=0)
    ap.add_argument("--channel",type=int,default=3)
    ap.add_argument("--action",type=int,default=1)
    ap.add_argument("--amplitude-q15",type=lambda x:int(x,0),default=0x4000)
    ap.add_argument("--duration-ticks",type=int,default=100)
    ap.add_argument("--payload0",type=lambda x:int(x,0),default=0x11223344)
    ap.add_argument("--payload1",type=lambda x:int(x,0),default=0x55667788)
    ap.add_argument("--output",default="build/qhap_dma_frame.bin")
    args=ap.parse_args()

    frame=pack_frame(1,0,args.sequence,args.channel,args.action,args.amplitude_q15,
                     args.duration_ticks,args.payload0,args.payload1)
    decoded=unpack_frame(frame)
    if len(frame)!=32 or not decoded.get("valid"):
        raise SystemExit("refusing to emit invalid QHAP DMA frame")

    out=Path(args.output)
    out.parent.mkdir(parents=True,exist_ok=True)
    out.write_bytes(frame)
    print(f"QART_DMA_FRAME_READY path={out} bytes={len(frame)} sequence={decoded['sequence']} crc={frame[28:32].hex()}")

if __name__=="__main__":
    main()
