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

@fragment
fn fs_main(@builtin(position) in_coord: vec4f) -> @location(0) vec4f {
    let r = (-cos(in_coord.x * 0.01) + 1.0) * 0.5;
    let g = (-cos(in_coord.y * 0.005) + 1.0) * 0.5;
    let b = 0.0;
    return vec4f(r, g, b, 1.0);
}
