# c 2023-12-28
# m 2026-01-28

import os
from zipfile import ZipFile, ZIP_DEFLATED


def count_lines(src: str) -> int:
    ret: int = 0

    for dir, _, files in os.walk(src):
        for file in files:
            if file.lower().endswith('.as'):
                path: str = f'{dir}/{file}'
                with open(path, encoding='utf-8') as file:
                    lines: int = 0

                    for line in file:
                        if all((
                            line,
                            line != '\n',
                            line != '\r\n',
                            not line.startswith('#'),
                            not line.startswith('//')
                        )):
                            lines += 1

                    print(f'found {lines} lines in {path}')
                    ret += lines

    return ret


def main() -> None:
    dir: str = os.getcwd()

    src: str = f'{dir}/src'
    if not os.path.isdir(src):
        print('src folder missing!')
        return

    print(f'plugin has {count_lines(src)} lines of code')

    license: str = f'{dir}/LICENSE.txt'
    if not os.path.isfile(license):
        print('LICENSE.txt missing!')
        return

    info: str = f'{dir}/info.toml'
    if not os.path.isfile(info):
        print('info.toml missing!')
        return

    has_assets: bool = True
    assets: str = f'{dir}/assets'
    if not os.path.isdir(assets):
        print('assets folder missing!')
        has_assets = False

    with open(info, 'r') as f:
        lines: list[str] = f.readlines()

    for line in lines:
        if 'version' in line:
            zip_name: str = dir.split('\\')[-1] + '_' + line.split(' ')[2].replace('"', '').replace('\n', '') + '.op'
            break

    with ZipFile(zip_name, 'w', ZIP_DEFLATED) as z:
        z.write(info, os.path.basename(info))
        z.write(license, os.path.basename(license))

        for dir, _, files in os.walk(src):
            for file in files:
                abspath: str = os.path.join(dir, file)
                z.write(abspath, os.path.relpath(abspath, os.path.join(src, '..')))

        if has_assets:
            for dir, _, files in os.walk(assets):
                for file in files:
                    abspath: str = os.path.join(dir, file)
                    z.write(abspath, os.path.relpath(abspath, os.path.join(assets, '..')))


if __name__ == '__main__':
    main()
