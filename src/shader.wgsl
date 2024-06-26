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

const LIGHT_POS = vec3f(10.0, -30.0, -20.0);

@group(0) @binding(0)
var<uniform> u_resolution: vec2f;

@fragment
fn fs_main(@builtin(position) in_coord: vec4f) -> @location(0) vec4f {
    let uv: vec2f = (2.0 * in_coord.xy - u_resolution.xy) / u_resolution.y;

    let op = vec3f(0., 0., -3.);
    let rd = normalize(vec3f(uv.x, uv.y, FOCAL_LENGTH));
    let p = ray_march(op, rd);

    let out = shade(p);
    return vec4f(out, 1.0);
}

fn shade(p: vec3f) -> vec3f {
    if map(p) > EPSILON {
        return vec3f(0.1, 0.2, 0.3); 
    }
    var color: vec3f;
    color = vec3f(1.0, 1.0, 1.0);

    let N = get_normal(p, EPSILON);
    let L = normalize(LIGHT_POS - p);
    color = clamp(dot(N, L), 0.0, 1.0) * color;

    return color;
}

fn get_normal(p: vec3f, epsilon: f32) -> vec3f {
    let e = vec2f(0.0, epsilon);
    let gradient_times_epsilon = vec3f(map(p + e.yxx), map(p + e.xyx), map(p + e.xxy)) - map(p);
    return normalize(gradient_times_epsilon);
}

fn ray_march(op: vec3f, rd: vec3f) -> vec3f {
    var dis = 0.0;
    for (var i = 0; i < MAX_LOOP_COUNT; i++) {
        let hit = map(op + dis * rd);
        if hit < EPSILON {
            break;
        }
        dis += hit;
        if dis > MAX_DISTANCE {
            break;
        }
    }
    return op + dis * rd;
}

fn map(p: vec3f) -> f32 {
    return ball(p, vec3f(0., 0., 0.), 1.);
}

fn ball(p: vec3f, c: vec3f, r: f32) -> f32 {
    return length(p - c) - r;
}
