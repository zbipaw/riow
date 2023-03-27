const std = @import("std");

const material = @import("material.zig");
const tup3 = @import("tup3.zig");
const ray = @import("ray.zig");

const Allocator = std.mem.Allocator;
const Color = tup3.Color;
const Material = material.Material;
const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Vec3 = tup3.Point3;

pub const Hittable = struct {
    hitFn: *const fn (self: *Hittable, r: Ray, t_min: f32, t_max: f32) ?HitRecord,

    pub fn hit(self: *Hittable, r: Ray, t_min: f32, t_max: f32) ?HitRecord {
        return self.hitFn(self, r, t_min, t_max);
    }
};

pub const HittableList = struct {
    hittable: Hittable,
    objects: std.ArrayList(*Hittable),
  
    const Self = @This();
    pub fn init(allocator: Allocator) Self {
        return Self {
            .hittable = Hittable { .hitFn = hit },
            .objects = std.ArrayList(*Hittable).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.objects.deinit();
    }

    pub fn add(self: *Self, obj: *Hittable) !void {
        try self.objects.append(obj);
    }

    fn hit(hittable: *Hittable, r: Ray, t_min: f32, t_max: f32) ?HitRecord {
        const self = @fieldParentPtr(Self, "hittable", hittable);

        var closest_so_far: f32 = t_max;
        var hit_anything = false;
        var hitrec: ?HitRecord = null;

        for (self.objects.items) |object| {
            if (object.hit(r, t_min, closest_so_far)) |rec| {
                closest_so_far = rec.t;
                hit_anything = true;
                hitrec = rec;
            }
        }
        return if (hit_anything) hitrec else null;
    }
};

pub const HitRecord = struct {
    front_face: bool,
    mat_ptr: *Material,
    normal: Vec3,
    p: Point3,
    t: f32,

    pub fn new(r: Ray, outward_normal: Vec3, root: f32) HitRecord {
        const p = r.at(root);
        const front_face = r.direction.dot(outward_normal) < 0;
        return HitRecord{
            .p = p,
            .normal = if (front_face) outward_normal else outward_normal.neg(),
            .t = root,
            .front_face = front_face,
        };
    }
};

pub const Sphere = struct {
    center: Point3,
    hittable: Hittable,
    mat_ptr: *Material,
    radius: f32,

    pub fn init(center: Point3, radius: f32, mat: *Material) Sphere {
        return Sphere {
            .center = center,
            .hittable = Hittable { .hitFn = hit },
            .radius = radius,
            .mat_ptr = mat,
        };
    }

    pub fn hit(hittable: *const Hittable, r: Ray, t_min: f32, t_max: f32) ?HitRecord {
        const self = @fieldParentPtr(Sphere, "hittable", hittable);

        const oc = r.origin.sub(self.center);
        const a = r.direction.lensq();
        const half_b = oc.dot(r.direction);
        const c = oc.lensq() - std.math.pow(f32, self.radius, 2);

        const discriminant = std.math.pow(f32, half_b, 2) - a * c;
        if (discriminant < 0) return null;
        const sqrtd = @sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        var root: f32 = (-half_b - sqrtd) / a;
        if (root < t_min or t_max < root) {
            root = (-half_b + sqrtd) / a;
            if (root < t_min or t_max < root) return null;
        }

        const p = r.at(root);
        const outward_normal = (p.sub(self.center)).div(self.radius);
        const front_face = r.direction.dot(outward_normal) < 0;

        var hitrec: HitRecord = undefined;
        hitrec.t = root;
        hitrec.p = p;
        hitrec.normal = if (front_face) outward_normal else outward_normal.neg();
        hitrec.front_face = front_face;
        hitrec.mat_ptr = self.mat_ptr;

        return hitrec;
    }
};
