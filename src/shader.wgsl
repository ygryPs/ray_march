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

const FOCAL_LENGTH = 1.0;
const MAX_LOOP_COUNT = 256;
const MAX_DISTANCE = 1000.0;
const EPSILON = 0.001;

@group(0) @binding(0)
var<uniform> u_resolution: vec2f;

@fragment
fn fs_main(@builtin(position) in_coord: vec4f) -> @location(0) vec4f {
    let uv: vec2f = (2.0 * in_coord.xy - u_resolution.xy) / u_resolution.y;

    let op = vec3f(0., 0., -3.);
    let rd = normalize(vec3f(uv.x, uv.y, FOCAL_LENGTH));

    var out: vec3f;
    if ray_march(op, rd) {
        out = vec3f(1.0, 1.0, 1.0);
    } else {
        out = vec3f(0.0, 0.0, 0.0);
    }
    return vec4f(out, 1.0);
}

fn ray_march(op: vec3f, rd: vec3f) -> bool {
    var dis = 0.0;
    for (var i = 0; i < MAX_LOOP_COUNT; i++) {
        let hit = map(op + dis * rd);
        if hit < EPSILON {
            return true;
        }
        dis += hit;
        if dis > MAX_DISTANCE {
            break;
        }
    }
    return false;
}

fn map(p: vec3f) -> f32 {
    return ball(p, vec3f(0., 0., 0.), 1.);
}

fn ball(p: vec3f, c: vec3f, r: f32) -> f32 {
    return length(p - c) - r;
}
