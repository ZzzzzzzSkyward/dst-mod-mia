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
        pt=0
        for idt,st in enumerate(data):
            st=st.strip()
            if pt>idt:
                continue
            if len(st)==0:
                continue
            if st[len(st)-1] not in {"{","="}:
                newdata.append(st.split("="))
                continue
            idt+=1
            tid=idt
            if idt>=len(data):
                continue
            while data[idt][:7]!="STRINGS":
                print(tid,idt)
                st+=data[idt].strip()
                idt+=1
                if idt>=len(data):
                    break
            newdata.append(st.split("="))
            pt=idt
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