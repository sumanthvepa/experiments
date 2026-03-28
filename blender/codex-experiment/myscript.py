# myscript.py
import bpy

# Delete default cube
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete(use_global=False)

# Add a UV sphere
bpy.ops.mesh.primitive_uv_sphere_add(location=(0, 0, 1))

# Save result
bpy.ops.wm.save_as_mainfile(filepath="output.blend")
