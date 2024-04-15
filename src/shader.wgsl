// Vertex shader

@vertex
fn vs_main(
    @builtin(vertex_index) in_vertex_index: u32,
) -> @builtin(position) vec4<f32> {
    let x = f32(i32(in_vertex_index & 1u) * 2 - 1);
    let y = f32(i32(in_vertex_index & 2u) - 1);
    return vec4<f32>(x, y, 0.0, 1.0);
}

// Fragment shader

@fragment
fn fs_main() -> @location(0) vec4<f32> {
    return vec4<f32>(
        0.3,
        0.5,
        0.4,
        1.0
    );
}
