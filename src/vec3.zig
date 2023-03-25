const std = @import("std");

const Vector = std.meta.Vector;

pub const Vec3 = Vector(3, f32);

pub fn cross(v1: Vec3, v2: Vec3) Vec3 {

    return [_]f32 {
        v1[1] * v2[2] - v1[2] * v2[1],
        v1[2] * v2[0] - v1[0] * v2[2],
        v1[0] * v2[1] - v1[1] * v2[0],
    };

}

pub fn dot(v1: Vec3, v2: Vec3) f32 { return @reduce(.Add, v1 * v2); }

pub fn length(v: Vec3) f32 { return @sqrt(length_squared(v)); }

pub fn length_squared(v: Vec3) f32 { return dot(v, v); }

pub fn scale(t: f32, v: Vec3) Vec3 {

    return Vec3 {
        v[0] * t,
        v[1] * t,
        v[2] * t,
    };

}

pub fn unit(v: Vec3) Vec3 { return scale(1.0 / length(v), v); }

// Type aliases for Vec3
pub const Point3 = Vec3;    // 3D point
pub const Color = Vec3;     // RGB color
