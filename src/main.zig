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
const Metal = material.Metal;
const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Sphere = objects.Sphere;
const Vec3 = tup3.Vec3;

fn four_spheres(allocator: Allocator) !HittableList {
    var world = HittableList.init(allocator);

    const mat1 = try allocator.create(Lambertian);
    mat1.* = Lambertian.init(Color.rgb(0.8, 0.8, 0.0));
    const sphere1 = try allocator.create(Sphere);
    sphere1.* = Sphere.init(Point3.pos(0, -100.5, -1), 100.0, &mat1.material);
    try world.add(&sphere1.hittable);

    const mat2 = try allocator.create(Lambertian);
    mat2.* = Lambertian.init(Color.rgb(0.1, 0.2, 0.5));
    const sphere2 = try allocator.create(Sphere);
    sphere2.* = Sphere.init(Point3.pos(0, 0, -1), 0.5, &mat2.material);
    try world.add(&sphere2.hittable);

    const mat3 = try allocator.create(Dielectric);
    mat3.* = Dielectric.init(1.5);
    const sphere3 = try allocator.create(Sphere);
    sphere3.* = Sphere.init(Point3.pos(-1, 0, -1), 0.5, &mat3.material);
    try world.add(&sphere3.hittable);

    const sphere5 = try allocator.create(Sphere);
    sphere5.* = Sphere.init(Point3.pos(-1, 0, -1), -0.4, &mat3.material);
    try world.add(&sphere5.hittable);

    const mat4 = try allocator.create(Metal);
    mat4.* = Metal.init(Color.rgb(0.8, 0.6, 0.2), 0.0);
    const sphere4 = try allocator.create(Sphere);
    sphere4.* = Sphere.init(Point3.pos(1, 0, -1), 0.5, &mat4.material);
    try world.add(&sphere4.hittable);

    return world;
}

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
    const max_depth: u32 = 64; 
    const samples_per_pixel: u32 = 256;

    //World
    var world = try four_spheres(allocator);

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
