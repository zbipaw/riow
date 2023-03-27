const std = @import("std");
const tup3 = @import("tup3.zig");

const Vec3 = Vec3.Tup3;

pub const e = 0.001;
pub const inf = std.math.inf_f32;
pub const pi = std.math.pi;

pub fn deg2rad(comptime T: type, deg: T) T {
    return deg * @as(T, pi) / @as(T, 180.0);
}

pub fn randf(comptime T: type, rand: anytype) T {
    return rand.float(T);
}

pub fn randrf(comptime T: type, lo: T, hi: T, rand: anytype) T {
    return lo + (hi - lo) * rand.float(T);
}

pub fn clamp(comptime T: type, x: T, lo: T, hi: T) T {
    if (x < lo) return lo;
    if (x > hi) return hi;
    return x;
}

pub fn clampv(comptime T: type, v: Vec3(T), lo: T, hi: T) Vec3(T) {
    var rv: Vec3(T) = undefined;
    rv[0] = clamp(T, v[0], lo, hi);
    rv[1] = clamp(T, v[1], lo, hi);
    rv[2] = clamp(T, v[2], lo, hi);
    return rv;
}
