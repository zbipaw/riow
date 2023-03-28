const std = @import("std");

const camera = @import("camera.zig");
const color = @import("color.zig");
const common = @import("common.zig");
const material = @import("material.zig");
const ray = @import("ray.zig");
const objects = @import("objects.zig");
const tup3 = @import("tup3.zig");

const Allocator = std.mem.Allocator;
const Camera = camera.Camera;
const Color = tup3.Color;
const Dielectric = material.Dielectric;
const HitRecord = objects.HitRecord;
const Hittable = objects.Hittable;
const HittableList = objects.HittableList;
const Lambertian = material.Lambertian;
const Material = material.Material;
const Metal = material.Metal;
const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Sphere = objects.Sphere;
const Vec3 = tup3.Vec3;

fn ray_color(r: Ray, world: *Hittable, depth: u32) Color {
    var hitrec: HitRecord = undefined;

    // If we've exceeded the ray bounce limit, no more light is gathered.
    if (depth <= 0) return Color.rgb(0.0, 0.0, 0.0);
    
    if (world.hit(r, common.e, common.inf, &hitrec)) {
        var scattered: Ray = undefined;
        var attenuation: Color = undefined;
        if (hitrec.mat_ptr.scatter(r, hitrec, &attenuation, &scattered))
            return attenuation.mulv(ray_color(scattered, world, depth - 1));
    }
    
    const unit_direction = r.direction.unit();
    const t: f32 = 0.5 * (unit_direction.y + 1.0);

    const white = Color.rgb(1.0, 1.0, 1.0);
    const blue = Color.rgb(0.5, 0.7, 1.0);
    const grad = white.mul(1.0 - t).add(blue.mul(t));
    return grad;
}

fn random_scene(allocator: Allocator) !HittableList {
    var world = HittableList.init(allocator);

    // Ground
    var ground_material = try allocator.create(Lambertian);
    ground_material.* = Lambertian.init(Color.rgb(0.5, 0.5, 0.5));
    var ground_sphere = try allocator.create(Sphere);
    ground_sphere.* = Sphere.init(Point3.pos(0, -1000, 0), 1000, &ground_material.material);
    try world.add(&ground_sphere.hittable);

    // Small spheres
    var a: i8= -11;
    while (a < 11) : (a += 1) {
        var b: i8 = -11;
        while (b < 11) : (b += 1) {
            const choose_mat = common.randf();
            const center = Point3.pos(@intToFloat(f32, a) + 0.9 * common.randf(), 0.2, @intToFloat(f32, b) + 0.9 * common.randf());

            if ((center.sub(Point3.pos(4, 0.2, 0)).len() > 0.9)) {
                if (choose_mat < 0.8) {
                    // Lambertian
                    const albedo = Color.rand().mulv(Color.rand());
                    var sphere_material = try allocator.create(Lambertian);
                    sphere_material.* = Lambertian.init(albedo);

                    var sphere = try allocator.create(Sphere);
                    sphere.* = Sphere.init(center, 0.2, &sphere_material.material);
                    try world.add(&sphere.hittable);
                } else if (choose_mat < 0.95) {
                    // Metal
                    const albedo = Color.randr(0.5, 1);
                    const fuzz = common.randrf(0, 0.5);
                    var sphere_material = try allocator.create(Metal);
                    sphere_material.* = Metal.init(albedo, fuzz);

                    var sphere = try allocator.create(Sphere);
                    sphere.* = Sphere.init(center, 0.2, &sphere_material.material);
                    try world.add(&sphere.hittable);
                } else {
                    // Dielectric
                    var sphere_material= try allocator.create(Dielectric);
                    sphere_material.* = Dielectric.init(1.5);

                    var sphere = try allocator.create(Sphere);
                    sphere.* = Sphere.init(center, 0.2, &sphere_material.material);
                    try world.add(&sphere.hittable);
                }
            }
        }
    }

    //Big spheres
    const material1 = try allocator.create(Dielectric);
    material1.* = Dielectric.init(1.5);
    const sphere1 = try allocator.create(Sphere);
    sphere1.* = Sphere.init(Point3.pos(0, 1, 0), 1.0, &material1.material);
    try world.add(&sphere1.hittable);

    const material2 = try allocator.create(Lambertian);
    material2.* = Lambertian.init(Color.rgb(0.4, 0.2, 0.1));
    const sphere2 = try allocator.create(Sphere);
    sphere2.* = Sphere.init(Point3.pos(-4, 1, 0), 1.0, &material2.material);
    try world.add(&sphere2.hittable);

    const material3 = try allocator.create(Metal);
    material3.* = Metal.init(Color.rgb(0.7, 0.6, 0.5), 0.0);
    const sphere3 = try allocator.create(Sphere);
    sphere3.* = Sphere.init(Point3.pos(4, 1, 0), 1.0, &material3.material);
    try world.add(&sphere3.hittable);

    return world;
}

pub fn main() !void {
    //allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    const allocator = arena.allocator();

    //stdio
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    
    //Image
    const aspect_ratio: f32 = 3.0 / 2.0;
    const image_width: u32 = 480;
    const image_height: u32 = @floatToInt(u32, @as(f32, image_width) / aspect_ratio);
    const max_depth: u32 = 16; 
    const samples_per_pixel: u32 = 64;

    //World
    var world = try random_scene(allocator);

    //Camera
    const cam_lookfrom = Point3.pos(13.0, 2.0, 3.0);
    const cam_lookat = Point3.pos(0.0, 0.0, 0.0);
    const cam_vup = Vec3.vec(0.0, 1.0, 0.0);
    const cam_ratio = aspect_ratio;
    const cam_vfov = 20.0;
    const cam_fnum = 0.1;
    const cam_focdist = 10; //cam_lookfrom.sub(cam_lookat).len();
    const cam = Camera.init(
        cam_lookfrom,
        cam_lookat,
        cam_vup,
        cam_ratio,
        cam_vfov,
        cam_fnum,
        cam_focdist,
    );

    //Render
    const dw = @as(f32, image_width - 1);
    const dh = @as(f32, image_height - 1);

    try stdout.print("P3\n{d} {d}\n255\n", .{image_width, image_height});

    var j: isize = image_height - 1;
    while (j >= 0) : (j -= 1) {
        try stderr.print("Scanlines remaining: {}\n", .{j});

        var i: usize = 0;
        while (i < image_width) : (i += 1) {
            var pixel_color = Color.rgb(0.0, 0.0, 0.0);

            var s: usize = 0;
            while (s < samples_per_pixel) : (s += 1) {
                const u = (@intToFloat(f32, i) + common.randf()) / dw;
                const v = (@intToFloat(f32, j) + common.randf()) / dh; 
                var r = cam.get_ray(u, v); 
                pixel_color.addi(ray_color(r, &world.hittable, max_depth));
            }

            try color.write_color(@TypeOf(stdout), stdout, pixel_color, samples_per_pixel);
        }
    }
    try stderr.print("Done\n", .{});
}
