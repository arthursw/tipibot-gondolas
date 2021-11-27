import cadquery as cq
from jupyter_cadquery.viewer.client import show

gondola_outer_diameter = 200
gondola_length = 170
arc_width = 25
rail_thickness = 5
thickness = 3

# arc = (cq.Workplane('XZ')
#     .circle(gondola_outer_diameter/2)
#     .circle((gondola_outer_diameter-arc_width)/2)
#     .extrude(thickness)
#     .transformed((-90,0,0))
#     .split(keepTop=True))

frontRing = (cq.Workplane('XZ')
    .circle(gondola_outer_diameter/2)
    .circle((gondola_outer_diameter-arc_width)/2)
    .extrude(thickness))

assembly = (
    cq.Assembly()
    .add(frontRing, loc=cq.Location(cq.Vector(0, gondola_length/2, 0)), color=cq.Color("green"))
    .add(frontRing, loc=cq.Location(cq.Vector(0, -gondola_length/2, 0)), color=cq.Color("red"))
    .add(frontRing, loc=cq.Location(cq.Vector(0, gondola_length/2-thickness, -gondola_outer_diameter/2)), color=cq.Color("green"))
    .add(frontRing, loc=cq.Location(cq.Vector(0, -gondola_length/2+thickness, -gondola_outer_diameter/2)), color=cq.Color("red"))
)

show(assembly, transparent=True)