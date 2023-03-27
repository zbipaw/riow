const std = @import("std");
const tup3 = @import("tup3.zig");

const Vec3 = Vec3.Tup3;

pub const e = 0.001;
pub const inf = std.math.inf_f32;
pub const pi = std.math.pi;

pub fn deg2rad(deg: f32) f32 {
    return deg * pi / 180.0;
}

pub fn randf() f32 {
    const seed: u64 = 0x000001;
    var prng = std.rand.DefaultPrng.init(seed);
    var rand = prng.random();
    return rand.float(f32);
}

pub fn randrf(lo: f32, hi: f32) f32 {
    return lo + (hi - lo) * randf();
}

pub fn clamp(x: f32, lo: f32, hi: f32) f32 {
    if (x < lo) return lo;
    if (x > hi) return hi;
    return x;
}
