import opencc
import os
t2s=opencc.OpenCC("t2s")
s2t=opencc.OpenCC("s2t")
srcfile="speech_nanachi_zht.lua"
dstfile=["speech_nanachi_zh.lua","speech_nanachi_zht.lua"]
dsttranslator=[t2s,s2t]
mask=[0,1]
if os.path.exists(srcfile):
    data=None
    with open(srcfile,"rb") as f:
         data=f.read()
         data=str(data,encoding="utf-8")
    for i,file in enumerate(dstfile):
         if not mask[i]:
             continue
         print("encoding",file)
         with open(file,"w") as f:
             f.write(dsttranslator[i].convert(data),encoding="utf-8")