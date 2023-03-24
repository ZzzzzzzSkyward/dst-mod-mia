from zzz import *
srcdir = ""
excluded=["exported","FUNDING.yml",".git",".gitignore","__pycache__",".vscode","exclude.txt"]
excluded_regexp=["py$"]
excluded_cmd=[".py",".po"]
dstdir = "z:\\mia\\"
def isexclude(x):
    e=x in excluded
    if e:
        return True
    for i in excluded_regexp:
        if reg.search(x,i):
            return True
    return False
files=os.listdir()
for i in files:
    if isexclude(i):
        continue
    try:
        if os.path.isdir(i):
            cmd("xcopy /s /y /exclude:exclude.txt "+srcdir+i+" "+dstdir+i+"\\ ")
        else:
            pass
            file.copy(srcdir+i, dstdir+i)
    except Exception as e:
        print(e)
