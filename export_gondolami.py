import subprocess
from pathlib import Path
import argparse

parser = argparse.ArgumentParser(description='Export Gondolami.')
parser.add_argument('-t', '--type', type=str, help='Export type', default='3d', choices=['3d', '2d'])
args = parser.parse_args()


# parts = ['kerf_test', 'tests', 'main_arc1', 'main_arc2', 'hlink', 'hlink_cap', 'double_caster', 'wing', 'vlink_with_comb', 
# 'pencil_holder', 'servo_case', 'body', 'point88_ensemble', 'pen_wedge', 'cap_holder', 'cap', 'pulley']
parts = ['servo_case']

export_command = args.type

file_format = 'stl' if export_command == '3d' else 'svg'

# kerf_widths = [0.1, 0.2, 0.3] if export_command == '2d' else [0]
kerf_widths = [0.1, 0.2, 0.3] if export_command == '2d' else [0]

for kerf_width in kerf_widths:
    print(f'kerf_width {kerf_width}')
    for gondola_length in [170]:
        print(f'gondola_length {gondola_length}')
        kerf_string = f'_kerf{kerf_width}' if export_command == '2d' else ''
        output_folder = Path(f'parts_length{gondola_length}{kerf_string}_{export_command}')
        output_folder.mkdir(exist_ok=True)
        for part in parts:
            # filename = f'{part}_length{gondola_length}.stl'
            print(f'   Export {part}...')
            filename = output_folder / f'{part}.{file_format}'
            command = ['/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD', f'-o{str(filename)}']
            command += [f'-Dgondola_length={gondola_length}', f'-Dcommand="{export_command}"']
            command += [f'-Dpart="{part}"', f'-Dkerf_width={kerf_width}', 'gondolami.scad']
            subprocess.run(command)
