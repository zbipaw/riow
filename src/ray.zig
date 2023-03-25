const vec3 = @import("vec3.zig");

const Point3 = vec3.Point3;
const Vec3 = vec3.Vec3;

const scale = vec3.scale;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    const Self = @This();

    pub fn at(self: *const Self, t: f32) Vec3 {
        return self.origin + scale(t, self.direction);
    }
    
};
