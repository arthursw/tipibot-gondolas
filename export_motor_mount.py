import subprocess
from pathlib import Path
import argparse

parser = argparse.ArgumentParser(description='Export Motor Mount.')
parser.add_argument('-t', '--type', type=str, help='Export type', default='3d', choices=['3d', '2d'])
args = parser.parse_args()

# parts = ['double-caster', 'structure', 'inside']

parts = ['body', 'nema_holder', 'body_cap', 'side', 'sensor_holder']

export_command = args.type

file_format = 'stl' if export_command == '3d' else 'svg'

kerf_widths = [0.1] if export_command == '2d' else [0]

for kerf_width in kerf_widths:
    print(f'kerf_width {kerf_width}')
    kerf_string = f'_kerf{kerf_width}' if export_command == '2d' else ''
    output_folder = Path(f'motor_mount_parts{kerf_string}_{export_command}')
    output_folder.mkdir(exist_ok=True)
    for part in parts:
        # filename = f'{part}_length{gondola_length}.stl'
        print(f'   Export {part}...')
        filename = output_folder / f'{part}.{file_format}'
        command = ['/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD', f'-o{str(filename)}']
        command += [f'-Dcommand="{export_command}"']
        command += [f'-Dpart="{part}"', f'-Dkerf_width={kerf_width}', 'motor_mount.scad']
        subprocess.run(command)
