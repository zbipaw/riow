const tup3 = @import("tup3.zig");
const ray = @import("ray.zig");

const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Vec3 = tup3.Vec3;

pub const Camera = struct {
    horizontal: Vec3,
    lower_left_corner: Point3,
    origin: Point3,
    vertical: Vec3,

    const Self = @This();
    pub fn init(origin: Point3, focal_length: Vec3, viewport_height: f32, viewport_width: f32) Self {
        const _horizontal = Vec3.vec(viewport_width, 0, 0);
        const _vertical = Vec3.vec(0, viewport_height, 0);
        return .{
            .origin = origin,
            .horizontal = _horizontal,
            .vertical = _vertical,
            .lower_left_corner = (
                origin
                .sub(_horizontal.mul(0.5))
                .sub(_vertical.mul(0.5))
                .sub(focal_length)
            )
        };       
    }

    pub fn get_ray(self: *const Self, u: f32, v: f32) Ray {
        return .{
            .origin = self.origin,
            .direction = (
                self.lower_left_corner
                .add(self.horizontal.mul(u))
                .add(self.vertical.mul(v))
                .sub(self.origin)
            )
        };
    }
};
