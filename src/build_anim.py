from zzz import *
import win32api
import zipfile
# in exported
exported_dir = "./"
xml_config_all = [[{
    "attr": "name",
    "value": "icon",
    "attr2": "duration",
    "value2": "4"
}, {
    "attr": "name",
    "value": "icon_angry",
    "attr2": "duration",
    "value2": "4"
}], [{
    "attr": "name",
    "value": "swap_reskin_tool",
    "attr2": "duration",
    "value2": "8"
}, {
    "attr": "name",
    "value": "reskin_tool01",
    "attr2": "duration",
    "value2": "2"
}]]
dyn_dirs = []
xml_config = []
# config here!
dyn_dirs_all = input("input all anims here:\n").split(" ")
dyn_dirs=dyn_dirs_all
xml_config=[xml_config_all[0],xml_config_all[0]]
# ds dir
ds_dir = "../"
# default exported as "exported"
relative_exported = "exported/"
# default anim as "anim"
relative_anim = "anim/"
# path to autocompiler( I renamed it into rr)
mod_tools = "D:/Steam/steamapps/common/Don't Starve Mod Tools/mod_tools/"
autocompiler = mod_tools + "autocompilerr.exe"
if not os.path.exists(autocompiler):
    autocompiler = mod_tools + "/autocompiler.exe"
dst_dir = "../"
relative_dyn = "anim/"
relative_img = "images/"
ds_exported = file.d(ds_dir + relative_exported)
# buildxml
buildxml_path = mod_tools + "tools/scripts/buildanimation.py"
py27 = mod_tools + "buildtools/windows/Python27/python.exe"


def unzipfile(dirpath, filename, newdir=None):
    with zipfile.ZipFile(dirpath + filename, 'r') as z:
        z.extractall(newdir if newdir else dirpath)

# filename itself contains full path
# file list is within dirpath


def zipfiles(dirpath, filename, filelist, isAppend=False):
    with zipfile.ZipFile(filename, 'a' if isAppend else 'w') as z:
        for i in filelist:
            z.write(dirpath + i, i)


def convert_to_bat_path(path):
    ret = path.replace("/", "\\")
    print(ret)
    return '"' + ret + '"'


def edit_build_xml(filepath, configs):
    # <Symbol name="icon"><Frame framenum="0" duration="1">
    def changeduration(build, symbol, frame):
        #print(frame, symbol, build)
        for cfg in configs:
            if symbol.getAttribute(cfg["attr"]) == cfg["value"]:
                frame.setAttribute(cfg["attr2"], cfg["value2"])
    DoXML(filepath, changeduration)


def pipeline():
    for index, i in enumerate(dyn_dirs):
        expdir = file.d(ds_exported + i)
        # generate build.bin
        file.remove(file.d(ds_dir + relative_anim) + i + ".zip")
        command = 'start "" "{exe}" "{pyfile}"'.format(
            exe=py27, pyfile=buildxml_path) + ' "{file}" {param}'.format(param="--outputdir {o}".format(o=ds_dir), file=expdir + i + ".zip")
        cmd(command)  # abigail_flower needs this, others don't
        input("Press Enter to continue...")

def main():
    pipeline()


if __name__ == "__main__":
    main()
