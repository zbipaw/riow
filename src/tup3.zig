const std = @import("std");
const common = @import("common.zig");

// Type aliases for Tup3
pub const Point3 = Tup3;    // 3D point
pub const Color = Tup3;     // RGB color
pub const Vec3 = Tup3;     // Vector

pub const Tup3 = struct {
    x: f32,
    y: f32,
    z: f32,

    // Fn aliases for Tup3
    pub fn pos(x: f32, y: f32, z: f32) Tup3 { return Tup3.new(x, y, z); }
    pub fn rgb(x: f32, y: f32, z: f32) Tup3 { return Tup3.new(x, y, z); }
    pub fn vec(x: f32, y: f32, z: f32) Tup3 { return Tup3.new(x, y, z); }

    pub fn new(x: f32, y: f32, z: f32) Tup3 {
        return Tup3 {
            .x = x,
            .y = y,
            .z = z 
        };
    }

    pub fn at(self: Tup3, axis: u2) f32 {
        return switch(axis) {
            0 => self.x,
            1 => self.y,
            2 => self.z,
            else => unreachable
        };
    }

    // Operations
    pub fn add(a: Tup3, b: Tup3) Tup3 {
        return Tup3 {
            .x = a.x + b.x,
            .y = a.y + b.y,
            .z = a.z + b.z,
        };
    }

    pub fn addi(a: *Vec3, b: Vec3) void {
        a.x += b.x;
        a.y += b.y;
        a.z += b.z;
    }

    pub fn div(a: Tup3, t: f32) Tup3 {
        return Tup3 {
            .x = a.x / t,
            .y = a.y / t,
            .z = a.z / t,
        };
    }

    pub fn mul(a: Tup3, t: f32,) Tup3 {
        return Tup3 {
            .x = a.x * t,
            .y = a.y * t,
            .z = a.z * t,
        };
    }

    pub fn mulv(a: Tup3, b: Tup3) Tup3 {
        return Tup3 {
            .x = a.x * b.x,
            .y = a.y * b.y,
            .z = a.z * b.z,
        };
    }

    pub fn neg(v: Tup3) Tup3 {
        return Tup3 {
            .x = -v.x,
            .y = -v.y,
            .z = -v.z,
        };
    }

    pub fn cross(a: Tup3, b: Tup3) Tup3 {
        return Tup3 {
            .x = a.y * b.z - a.z * b.y,
            .y = a.z * b.x - a.x * b.z,
            .z = a.x * b.y - a.y * b.x,
        };
    }

    pub fn dot(a: Tup3, b: Tup3) f32 {
        return a.x * b.x + a.y * b.y + a.z * b.z;
    }

    pub fn len(v: Tup3) f32 {
        return @sqrt(len_sq(v));
    }

    pub fn len_sq(v: Tup3) f32 {
        return dot(v, v);
    }

    pub fn rand(randgen: std.rand.Random) Tup3 { 
        return Tup3 {
            .x = common.randf(f32, randgen),
            .y = common.randf(f32, randgen),
            .z = common.randf(f32, randgen),
        };
    }

    pub fn randr(lo: f32, hi: f32, randgen: std.rand.Random) Tup3 {
        return common.randrf(f32, lo, hi, randgen);
    }

    pub fn sub(a: Tup3, b: Tup3) Tup3 {
        return Tup3 {
            .x = a.x - b.x,
            .y = a.y - b.y,
            .z = a.z - b.z,
        };
    }

    pub fn unit(v: Tup3) Tup3 {
        return v.div(len(v)); 
    }
};
