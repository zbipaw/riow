const std = @import("std");

const ray = @import("ray.zig");
const objects = @import("objects.zig");
const tup3 = @import("tup3.zig");

const Allocator = std.mem.Allocator;
const Color = tup3.Color;
const HitRecord = objects.HitRecord;
const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Vec3 = tup3.Point3;

pub const Material = struct {
    scatterFn: *const fn (self: *Material, r: Ray, hitrec: HitRecord, attenuation: *Color, scattered: *Ray) bool,

    pub fn scatter(self: *Material, r: Ray, hitrec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        return self.scatterFn(self, r, hitrec, attenuation, scattered);
    }
};

pub const Lambertian = struct {
    albedo: Color,
    material: Material,

    pub fn init(a: Color) Lambertian {
        return Lambertian {
            .albedo = a,
            .material = Material { .scatterFn = scatter },
        };
    }

    pub fn scatter(material: *Material, r: Ray, hitrec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        _ = r;
        const self = @fieldParentPtr(Lambertian, "material", material);

        var scatter_direction: Vec3 = tup3.rand_ihemi(hitrec.normal);
        // Catch degenerate scatter direction
        if (scatter_direction.small()) scatter_direction = hitrec.normal;

        scattered.* = Ray.new(hitrec.p, scatter_direction);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const Metal = struct {
    albedo: Color,
    fuzz: f32,
    material: Material,

    pub fn init(a: Color, f: f32) Metal {
        return .{
            .albedo = a,
            .material = Material { .scatterFn = scatter },
            .fuzz = if (f < 1) f else 1.0,
        };
    }

    pub fn scatter(material: *Material, r: Ray, hitrec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const self = @fieldParentPtr(Metal, "material", material);

        const reflected = tup3.reflect(r.direction.unit(), hitrec.normal);
        const fuzzed = reflected.add(tup3.rand_ihemi(hitrec.normal).mul(self.fuzz));

        scattered.* = Ray.new(hitrec.p, fuzzed);
        attenuation.* = self.albedo;

        return scattered.direction.dot(hitrec.normal) > 0;
    }
};
