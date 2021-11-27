import subprocess
import re

regex = r"ECHO: num_components = (\d+)"
# output = """ECHO: num_components = 11
# Geometries in cache: 37
# Geometry cache size in bytes: 139944
# CGAL Polyhedrons in cache: 7
# CGAL cache size in bytes: 872368
# Total rendering time: 0:00:03.542
#    Top level object is a 2D object:
#    Contours:        1

# []"""

part_index = 0
n_parts = 1

while part_index < n_parts:
    filename = 'part_' + str(part_index) + '.svg'
    command = '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD -o{} -Drender_index={} gondola.scad'.format(filename, part_index)
    print(command.split())
    # subprocess.run(command.split())
    process = subprocess.Popen(command.split(), shell=False,
                           stdout=subprocess.PIPE, 
                           stderr=subprocess.PIPE)

    # wait for the process to terminate
    out, err = process.communicate()
    out = err.decode()
    errcode = process.returncode

    matches = list(re.finditer(regex, out, re.MULTILINE))

    n_parts = int(matches[0].group(1))
    part_index += 1