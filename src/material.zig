const std = @import("std");

const common = @import("common.zig");
const objects = @import("objects.zig");
const ray = @import("ray.zig");
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

pub const Dielectric = struct {
    ir: f32,
    material: Material,

    pub fn init(refindex: f32) Dielectric {
        return .{
            .material = Material { .scatterFn = scatter },
            .ir = refindex,
        };
    }

    pub fn scatter(material: *Material, r: Ray, hitrec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const self = @fieldParentPtr(Dielectric, "material", material);

        attenuation.* = Color.rgb(1.0, 1.0, 1.0);
        const refratio = if (hitrec.front_face) 1.0 / self.ir else self.ir;

        const unit_direction = r.direction.unit();
        const cost = std.math.min(unit_direction.neg().dot(hitrec.normal), 1.0);
        const sint = @sqrt(1.0 - cost * cost);

        const cannot_refract = refratio * sint > 1.0;

        const direction = if (cannot_refract or reflectance(cost, refratio) > common.randf())
            tup3.reflect(unit_direction, hitrec.normal)
        else
            tup3.refract(unit_direction, hitrec.normal, refratio);

        scattered.* = Ray.new(hitrec.p, direction);
        return true;
    }

    fn reflectance(cos: f32, ref_idx: f32) f32 {
        var r0 = (1 - ref_idx) / (1 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * std.math.pow(f32, 1 - cos, 5);
    }
};
