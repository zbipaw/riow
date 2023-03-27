const std = @import("std");

const ray = @import("ray.zig");
const tup3 = @import("tup3.zig");

const Allocator = std.mem.Allocator;
const Color = tup3.Color;
const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Vec3 = tup3.Point3;

pub const Hittable = struct {
    hitFn: *const fn (self: *const Hittable, r: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool,

    pub fn hit(self: *const Hittable, r: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        return self.hitFn(self, r, t_min, t_max, rec);
    }
};

pub const HittableList = struct {
    hittable: Hittable,
    objects: std.ArrayList(*Hittable),
  
    pub fn init(allocator: Allocator) HittableList {
        return HittableList {
            .hittable = Hittable { .hitFn = hit },
            .objects = std.ArrayList(*Hittable).init(allocator),
        };
    }

    pub fn deinit(self: *HittableList) void {
        self.objects.deinit();
    }

    pub fn add(self: *HittableList, obj: *Hittable) !void {
        try self.objects.append(obj);
    }

    fn hit(hittable: *const Hittable, r: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        const self = @fieldParentPtr(HittableList, "hittable", hittable);

        var closest_so_far = t_max;
        var hit_anything = false; 
        var temp_rec: HitRecord = undefined;

        for (self.objects.items) |object| {
            if (object.hit(r, t_min, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        return hit_anything;
    }
};

pub const HitRecord = struct {
    front_face: bool,
    normal: Vec3,
    p: Point3,
    t: f32,

    pub fn set_face_normal(self: *HitRecord, r: Ray, outward_normal: Vec3) void {
        self.front_face = r.direction.dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.neg();
    }
};

pub const Sphere = struct {
    center: Point3,
    hittable: Hittable,
    radius: f32,

    pub fn init(center: Point3, radius: f32) Sphere {
        return Sphere {
            .center = center,
            .hittable = Hittable { .hitFn = hit },
            .radius = radius,
        };
    }

    pub fn hit(hittable: *const Hittable, r: Ray, t_min: f32, t_max: f32, hitrec: *HitRecord) bool {
        const self = @fieldParentPtr(Sphere, "hittable", hittable);

        const oc = r.origin.sub(self.center);
        const a = r.direction.lensq();
        const half_b = oc.dot(r.direction);
        const c = oc.lensq() - std.math.pow(f32, self.radius, 2);

        const discriminant = std.math.pow(f32, half_b, 2) - a * c;
        if (discriminant < 0) return false;
        const sqrtd = @sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        var root: f32 = (-half_b - sqrtd) / a;
        if (root < t_min or t_max < root) {
            root = (-half_b + sqrtd) / a;
            if (root < t_min or t_max < root) return false;
        }

        hitrec.t = root;
        hitrec.p = r.at(hitrec.t);
        const outward_normal = hitrec.p.sub(self.center).div(self.radius);
        hitrec.set_face_normal(r, outward_normal);

        return true;
    }
};
