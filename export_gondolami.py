import subprocess
from pathlib import Path
import argparse




# main_arc1 main_arc2 hlink hlink_cap sliding_vlink sliding_hlink_top sliding_hlink_bottom double_caster wing vlink_with_comb servo_case body point88_ensemble cap_holder cap wheel
# p_nema p_weight p_waffle
# mm_body mm_nema_holder mm_body_cap mm_side mm_sensor_holder

models = {
    'gondolami': ['kerf_test', 'tests', 'main_arc1', 'main_arc2', 'hlink', 'hlink_cap', 'sliding_vlink', 'sliding_hlink_top', 'sliding_hlink_bottom', 'double_caster', 'wing', 'vlink_with_comb', 
'pencil_holder', 'servo_case', 'body', 'point88_ensemble', 'pen_wedge', 'cap_holder', 'cap', 'pulley', 'wheel', 'bearing_wheel'],
    # 'gondolami': ['main_arc1', 'main_arc2', 'hlink', 'hlink_cap', 'double_caster', 'wing', 'vlink_with_comb', 'servo_case', 'body', 'point88_ensemble', 'cap_holder', 'cap'],
    'pulley': ['p_nema', 'p_weight', 'p_waffle'],
    'motor_mount': ['mm_body', 'mm_nema_holder', 'mm_body_cap', 'mm_side', 'mm_sensor_holder']
}

all_parts = models['gondolami'] + models['pulley'] + models['motor_mount']

parser = argparse.ArgumentParser(description='Export Gondolami.', formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-t', '--type', type=str, help='Export type', default='3d', choices=['3d', '2d'])
parser.add_argument('-p', '--parts', help='Parts (default export all parts).', default=[], nargs='+', choices=all_parts)
parser.add_argument('-kw', '--kerf_widths', help='Kerf widths', default=[0.1, 0.2], nargs='+', type=float)
parser.add_argument('-gl', '--gondola_lengths', help='Gondola length', default=[120], nargs='+', type=float)
args = parser.parse_args()

parts = args.parts if len(args.parts) > 0 else all_parts

export_command = args.type

file_format = 'stl' if export_command == '3d' else 'svg'

# kerf_widths = [0.1, 0.2, 0.3] if export_command == '2d' else [0]
kerf_widths = args.kerf_widths if export_command == '2d' else [0]

def get_model_for_part(part):
    for m in models:
        if part in models[m]: return m
    return

for kerf_width in kerf_widths:
    print(f'kerf_width {kerf_width}')
    for gondola_length in args.gondola_lengths:
        print(f'gondola_length {gondola_length}')
        for part in parts:
            kerf_string = f'_kerf{kerf_width}' if export_command == '2d' else ''
            model = get_model_for_part(part)
            output_folder = Path(f'{model}_parts_length{gondola_length}{kerf_string}_{export_command}')
            output_folder.mkdir(exist_ok=True)
            # filename = f'{part}_length{gondola_length}.stl'
            print(f'   Export {model} {part}...')
            filename = output_folder / f'{part}.{file_format}'
            command = ['/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD', f'-o{str(filename)}']
            command += [f'-Dgondola_length={gondola_length}', f'-Dcommand="{export_command}"']
            command += [f'-Dpart="{part}"', f'-Dkerf_width={kerf_width}', f'{model}.scad']
            subprocess.run(command)
