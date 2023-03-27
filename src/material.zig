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
    scatterFn: *const fn (self: *Material, r: Ray, hitrec: HitRecord) ?MaterialRecord,

    pub fn scatter(self: *Material, r: Ray, hitrec: HitRecord) ?MaterialRecord {
        return self.scatterFn(self, r, hitrec);
    }
};

pub const MaterialRecord = struct {
    ray: Ray,
    attenuation: Color,
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

    pub fn scatter(material: *Material, r: Ray, hitrec: HitRecord) ?MaterialRecord {
        _ = r;
        const self = @fieldParentPtr(Lambertian, "material", material);

        var scatter_direction: Vec3 = tup3.rand_ihemi(hitrec.normal);
        // Catch degenerate scatter direction
        if (scatter_direction.small()) scatter_direction = hitrec.normal;

        const new_ray = Ray.new(hitrec.p, scatter_direction);
        return MaterialRecord {
            .ray = new_ray,
            .attenuation = self.albedo,
        };
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

    pub fn scatter(material: *Material, r: Ray, hitrec: HitRecord) ?MaterialRecord {
        const self = @fieldParentPtr(Metal, "material", material);

        const reflected = tup3.reflect(r.direction.unit(), hitrec.normal);
        const fuzzed = reflected.add(tup3.rand_ius().mul(self.fuzz));

        const new_ray = Ray.new(hitrec.p, fuzzed);
        return if (fuzzed.dot(hitrec.normal) > 0) MaterialRecord {
            .ray = new_ray,
            .attenuation = self.albedo,
        } else null;
    }
};
