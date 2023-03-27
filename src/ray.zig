const tup3 = @import("tup3.zig");

const Point3 = tup3.Point3;
const Vec3 = tup3.Tup3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    pub fn new(origin: Point3, direction: Vec3) Ray {
        return .{.origin = origin, .direction = direction};
    }

    pub fn at(self: Ray, t: f32) Vec3 {
        return self.origin.add(self.direction.mul(t));
    }
};
