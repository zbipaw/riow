const tup3 = @import("tup3.zig");

const Point3 = tup3.Point3;
const Vec3 = tup3.Tup3;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    const Self = @This();
    pub fn at(self: *const Self, t: f32) Point3 {
        return self.origin.add(self.direction.mul(t));
    }
};
