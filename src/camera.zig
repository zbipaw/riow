const std = @import("std");
const common = @import("common.zig");
const ray = @import("ray.zig");
const tup3 = @import("tup3.zig");

const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Vec3 = tup3.Vec3;

pub const Camera = struct {
    horizontal: Vec3,
    lens_radius: f32,
    lower_left_corner: Point3,
    origin: Point3,
    vertical: Vec3,
    w: Vec3,
    u: Vec3,
    v: Vec3,

    pub fn init(
        lookfrom: Point3,
        lookat: Point3,
        vup: Vec3,
        aspect_ratio: f32,
        vfov: f32,
        aperture: f32,
        focus_dist: f32,
    ) Camera {
        const _theta = common.deg2rad(vfov);

        const _h = @tan(_theta / 2);
        const _viewport_height = 2.0 * _h;
        const _viewport_width = aspect_ratio * _viewport_height;

        const _w = lookfrom.sub(lookat).unit();
        const _u = vup.cross(_w).unit();
        const _v = _w.cross(_u);

        const _origin = lookfrom;
        const _horizontal = _u.mul(focus_dist * _viewport_width);
        const _vertical = _v.mul(focus_dist * _viewport_height);

        return .{
            .origin = _origin,
            .horizontal = _horizontal,
            .vertical = _vertical,
            .lower_left_corner = (
                _origin
                .sub(_horizontal.mul(0.5))
                .sub(_vertical.mul(0.5))
                .sub(_w.mul(focus_dist))
            ),
            .lens_radius = aperture / 2.0,
            .u = _u,
            .v = _v,
            .w = _w,
        };       
    }

    pub fn get_ray(self: *const Camera, s: f32, t: f32) Ray {
        const rd = tup3.rand_idisk().mul(self.lens_radius);
        const offset = self.u.mul(rd.x).add(self.v.mul(rd.y));

        return Ray.new(
            self.origin.add(offset),
            self.lower_left_corner
                .add(self.horizontal.mul(s))
                .add(self.vertical.mul(t))
                .sub(self.origin)
                .sub(offset)
        );
    }
};
