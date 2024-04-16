// Vertex shader

@vertex
fn vs_main(
    @builtin(vertex_index) in_vertex_index: u32,
) -> @builtin(position) vec4f {
    let x = f32(i32(in_vertex_index & 1u) * 2 - 1);
    let y = f32(i32(in_vertex_index & 2u) - 1);
    return vec4f(x, y, 0.0, 1.0);
}

// Fragment shader

const PI: f32 = 3.14159265;

@group(0) @binding(0)
var<uniform> u_resolution: vec2f;

@fragment
fn fs_main(@builtin(position) in_coord: vec4f) -> @location(0) vec4f {
    let uv: vec2f = (2.0 * in_coord.xy - u_resolution.xy) / u_resolution.y;

    let r = (cos(PI * uv.x) + 1.0) * 0.5;
    let g = (cos(PI * uv.y) + 1.0) * 0.5;
    let b = 0.0;
    return vec4f(r, g, b, 1.0);
}
