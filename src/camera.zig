const std = @import("std");
const common = @import("common.zig");
const ray = @import("ray.zig");
const tup3 = @import("tup3.zig");

const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Vec3 = tup3.Vec3;

pub const Camera = struct {
    horizontal: Vec3,
    lower_left_corner: Point3,
    origin: Point3,
    vertical: Vec3,

    const Self = @This();
    pub fn init(lookfrom: Point3, lookat: Point3, vup: Vec3, aspect_ratio: f32, vfov: f32) Self {
        const _theta = common.deg2rad(vfov);

        const _h = @tan(_theta / 2);
        const _viewport_height = 2.0 * _h;
        const _viewport_width = aspect_ratio * _viewport_height;

        const _w = lookfrom.sub(lookat).unit();
        const _u = vup.cross(_w).unit();
        const _v = _w.cross(_u);

        const _origin = lookfrom;
        const _horizontal = Vec3.vec(_viewport_width, 0, 0);
        const _vertical = Vec3.vec(0, _viewport_height, 0);

        return .{
            .origin = _origin,
            .horizontal = _u.mul(_viewport_width),
            .vertical = _v.mul(_viewport_height),
            .lower_left_corner = (
                _origin
                .sub(_horizontal.mul(0.5))
                .sub(_vertical.mul(0.5))
                .sub(_w)
            )
        };       
    }

    pub fn get_ray(self: *const Self, s: f32, t: f32) Ray {
        return Ray.new(
            self.origin,
            self.lower_left_corner
                .add(self.horizontal.mul(s))
                .add(self.vertical.mul(t))
                .sub(self.origin)
        );
    }
};
