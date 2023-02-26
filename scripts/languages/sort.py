import os
dstfile=["mia_zh.lua","mia_en.lua"]
def compare(a):
    return a[0]
for file in dstfile:
    if os.path.exists(file):
        data=None
        with open(file,"rb") as f:
             data=f.read()
             data=str(data,encoding="utf-8")
             data=data.split("\n")
        print("sorting",file)
        newdata=[]
        for i in data:
            newdata.append(i.split("="))
        for i in newdata:
            for j in range(len(i)):
                i[j]=i[j].strip()
        newdata.sort(key=compare)
        stringifyed=[]
        for i in newdata:
            stringifyed.append(" = ".join(i))
        data="\n".join(stringifyed)
        data=bytes(data,encoding="utf-8")
        with open(file,"wb") as f:
             f.write(data)