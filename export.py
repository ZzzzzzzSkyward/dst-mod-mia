from zzz import *
srcdir = ""
excluded=["exported","FUNDING.yml",".git",".gitignore","__pycache__",".vscode"]
excluded_regexp=[".py$"]
dstdir = "z:\\mia\\"
def isexclude(x):
    e=x in excluded
    if e:
        return True
    for i in excluded_regexp:
        if reg.search(i,x):
            return True
    return False
files=os.listdir()
for i in files:
    if isexclude(i):
        continue
    try:
        if os.path.isdir(i):
            cmd("xcopy /s /y "+srcdir+i+" "+dstdir+i+"\\")
        else:
            pass
            file.copy(srcdir+i, dstdir+i)
    except Exception as e:
        print(e)