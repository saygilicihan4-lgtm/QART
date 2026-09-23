import struct,zlib
MAGIC=0x51484150; VERSION=2
FMT_NOCRC="<IBBH I H H H H I I"
def pack_frame(kind,flags,seq,channel,action,amp,duration,p0=0,p1=0):
    raw=struct.pack(FMT_NOCRC,MAGIC,VERSION,kind,flags,seq,channel,action,amp,duration,p0,p1)
    return raw+struct.pack("<I",zlib.crc32(raw)&0xffffffff)
def unpack_frame(data):
    if len(data)!=32:return {"valid":False,"reason":"length"}
    raw,got=data[:28],struct.unpack("<I",data[28:])[0]
    if (zlib.crc32(raw)&0xffffffff)!=got:return {"valid":False,"reason":"crc"}
    vals=struct.unpack(FMT_NOCRC,raw)
    magic,ver,kind,flags,seq,ch,action,amp,dur,p0,p1=vals
    if magic!=MAGIC or ver!=VERSION:return {"valid":False,"reason":"header"}
    if kind not in (1,2,3,4) or ch>=64 or action>2 or amp>0x7fff or not 1<=dur<=0xffff:return {"valid":False,"reason":"bounds"}
    return {"valid":True,"kind":kind,"sequence":seq,"channel":ch,"action":action,"amplitude_q15":amp,"duration_ticks":dur,"payload":[p0,p1]}
