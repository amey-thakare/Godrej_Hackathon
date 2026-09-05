import struct
import base64

# A simple quad (width 1, height 1)
# Positions (vec3 float32): 4 vertices = 4 * 3 * 4 = 48 bytes
# (-0.5, -0.5, 0), (0.5, -0.5, 0), (-0.5, 0.5, 0), (0.5, 0.5, 0)
positions = struct.pack('<12f', 
    -0.5, -0.5, 0.0,
     0.5, -0.5, 0.0,
    -0.5,  0.5, 0.0,
     0.5,  0.5, 0.0
)

# Normals (vec3 float32): 4 * 3 * 4 = 48 bytes
# (0, 0, 1) for all
normals = struct.pack('<12f',
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0
)

# UVs (vec2 float32): 4 * 2 * 4 = 32 bytes
# (0, 1), (1, 1), (0, 0), (1, 0)
uvs = struct.pack('<8f',
    0.0, 1.0,
    1.0, 1.0,
    0.0, 0.0,
    1.0, 0.0
)

# Indices (uint16): 2 triangles = 6 indices = 12 bytes
# 0, 1, 2,  2, 1, 3
indices = struct.pack('<6H', 0, 1, 2, 2, 1, 3)

buffer_data = positions + normals + uvs + indices
b64 = base64.b64encode(buffer_data).decode('utf-8')
print("Base64 buffer length:", len(b64))
print("Base64 buffer:", b64)

# Print offsets and lengths
pos_offset = 0
pos_len = 48
norm_offset = 48
norm_len = 48
uv_offset = 96
uv_len = 32
ind_offset = 128
ind_len = 12

print(f"pos: {pos_offset} len {pos_len}")
print(f"norm: {norm_offset} len {norm_len}")
print(f"uv: {uv_offset} len {uv_len}")
print(f"ind: {ind_offset} len {ind_len}")
