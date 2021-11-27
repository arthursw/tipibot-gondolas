import subprocess

parts = ['double-caster', 'structure', 'inside']

for gondola_length in [150, 170]:
    for part in parts:
        filename = part + '_length' + str(gondola_length) + '.stl'
        command = '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o{} -Dgondola_length={} -Dpart={} gondolami.scad'.format(filename, gondola_length, part)
        print(command.split())
        subprocess.run(command.split())