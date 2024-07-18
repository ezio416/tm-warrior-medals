# c 2023-12-28
# m 2024-01-22

import os
from zipfile import ZipFile, ZIP_DEFLATED


def main():
    dir: str = os.getcwd()

    src: str = dir + '/src'
    if not os.path.isdir(src):
        print('src folder missing!')
        return

    license: str = dir + '/LICENSE.txt'
    if not os.path.isfile(license):
        print('LICENSE.txt missing!')
        return

    info: str = dir + '/info.toml'
    if not os.path.isfile(info):
        print('info.toml missing!')
        return

    with open(info, 'r') as f:
        lines: list[str] = f.readlines()

    for line in lines:
        if 'version' in line:
            zipname: str = dir.split('\\')[-1] + '_' + line.split(' ')[2].replace('"', '').replace('\n', '') + '.op'
            break

    new_zipname: str = dir + '/versions/unsigned/' + zipname

    with ZipFile(zipname, 'w', ZIP_DEFLATED) as z:
        z.write(info, os.path.basename(info))
        z.write(license, os.path.basename(license))

        for dir, subdirs, files in os.walk(src):
            for file in files:
                abspath: str = os.path.join(dir, file)
                z.write(abspath, os.path.relpath(abspath, os.path.join(src, '..')))

    if os.path.isfile(new_zipname):
        print(zipname + ' already exists in unsigned folder!')
        return

    os.rename(zipname, new_zipname)


if __name__ == '__main__':
    main()
