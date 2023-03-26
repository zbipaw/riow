const std = @import("std");
const vec3 = @import("vec3.zig");

const Vec3 = vec3.Vec3;

pub const e = 0.001;
pub const inf = std.math.inf_f32;
pub const pi = std.math.pi;

pub fn deg_to_rad(comptime T: type, degrees: T) T {
    return degrees * @as(T, pi) / @as(T, 180.0);
}
