import shutil
import os
import xml.etree.ElementTree as ET
import sys
import re

def replace_names_in_file(file_path, name,export_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    for texture in root.iter('Texture'):
        texture.set('filename', f'names_{name}.tex')
    for element in root.iter('Element'):
        element.set('name', f'{name}.tex')
    tree.write(export_path)


def replace_names_in_directory(directory_path,force):
    for i in os.listdir(directory_path):
        if i.endswith('.xml') and i.startswith('names_') and i.find('gold') < 0:
            filepath = os.path.join(
                directory_path, i)
            try:
                name = re.search(r'names_([^.]+)', i).group(1)
                print("processing",name)
                exportpath = os.path.join(directory_path, f'names_{name}.xml')
                goldpath = os.path.join(directory_path, f'names_gold_{name}.xml')
                replace_names_in_file(
                    filepath, name,exportpath)
                copy_rename_files(exportpath, goldpath,force)
            except Exception:
                pass

def copy_rename_files(old_name, new_name,force=False):
    if os.path.exists(new_name) and not force:
        return
    shutil.copy(old_name, new_name)
    shutil.copy(old_name.replace('xml', 'tex'), new_name.replace('xml', 'tex'))


if __name__ == '__main__':
    path = "./"
    if len(sys.argv) > 1:
        path = sys.argv[1]
    force=False
    if len(sys.argv)>2:
        force=True
    replace_names_in_directory(path,force)
