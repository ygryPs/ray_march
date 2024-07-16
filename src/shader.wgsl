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

const FOCAL_LENGTH = 1.5;
const MAX_LOOP_COUNT = 256;
const MAX_DISTANCE = 1000.0;
const EPSILON = 0.001;

const LIGHT_POS = vec3f(10.0, 30.0, -20.0);

const CAM_POS = vec3f(-2., 5., -5.);
const ROT_X = 30. * PI / 180.;
const ROT_Y = -30. * PI / 180.;

const BLEND = .3;

@group(0) @binding(0)
var<uniform> u_resolution: vec2f;

@fragment
fn fs_main(@builtin(position) in_coord: vec4f) -> @location(0) vec4f {
    let CAMERA_TRANSFORM = mat3x3f(
        cos(ROT_Y), 0., sin(ROT_Y),
        -sin(ROT_X)*sin(ROT_Y), cos(ROT_X), sin(ROT_X)*cos(ROT_Y),
        -cos(ROT_X)*sin(ROT_Y), -sin(ROT_X), cos(ROT_X)*cos(ROT_Y),
    );

    var uv: vec2f = (2.0 * in_coord.xy - u_resolution.xy) / u_resolution.y;
    uv.y = -uv.y;

    let op = CAM_POS;
    let rd = CAMERA_TRANSFORM * normalize(vec3f(uv.x, uv.y, FOCAL_LENGTH));
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
    var res: f32;
    res = p.y;
    res = smin(res, sdSphere(p-vec3f(0., 1., 0.), 1.), BLEND);
    res = smin(res, sdSphere(p-vec3f(0., 1., 2.), 1.), BLEND);
    res = smin(res, sdSphere(p-vec3f(2., 1., 0.), 1.), BLEND);
    res = smin(res, sdSphere(p-vec3f(2., 1., 2.), 1.), BLEND);
    res = smin(res, sdSphere(p-vec3f(1., 2.42, 1.), 1.), BLEND);
    return res;
}

// exponential
fn smin( a: f32, b: f32, k: f32 ) -> f32
{
    let r: f32 = exp2(-a/k) + exp2(-b/k);
    return -k*log2(r);
}

fn sdSphere( p: vec3f, s: f32 ) -> f32
{
    return length(p)-s;
}
