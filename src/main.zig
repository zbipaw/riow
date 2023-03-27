const std = @import("std");

const camera = @import("camera.zig");
const color = @import("color.zig");
const common = @import("common.zig");
const ray = @import("ray.zig");
const objects = @import("objects.zig");
const tup3 = @import("tup3.zig");

const Camera = camera.Camera;
const Color = tup3.Color;
const HitRecord = objects.HitRecord;
const Hittable = objects.Hittable;
const HittableList = objects.HittableList;
const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Sphere = objects.Sphere;
const Vec3 = tup3.Vec3;

fn populate_2spheres(allocator: std.mem.Allocator) !HittableList {
    const sphere1 = try allocator.create(Sphere);
    sphere1.* = Sphere.init(Point3.pos(0, 0, -1), 0.5);
    const sphere2 = try allocator.create(Sphere);
    sphere2.* = Sphere.init(Point3.pos(0, -100.5, -1), 100);
    
    var world = HittableList.init(allocator);
    try world.add(&sphere1.hittable);
    try world.add(&sphere2.hittable);
    return world;
}

fn ray_color(r: *Ray, world: *const Hittable) Color {
    var hitrec: HitRecord = undefined;
    if (world.hit(r, common.e, common.inf, &hitrec)) return hitrec.normal.add(Color.rgb(1, 1, 1)).mul(0.5);
    
    const unit_direction = Vec3.unit(r.direction);
    const t: f32 = 0.5 * (unit_direction.y + 1.0);

    const white = Color.rgb(1.0, 1.0, 1.0);
    const blue = Color.rgb(0.5, 0.7, 1.0);
    const grad = white.mul(t).add(blue.mul(t));
    return grad;
}

pub fn main() !void {

    //allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    //stdio
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    
    //Image
    const aspect_ratio: f32 = 16.0 / 9.0;
    const image_width: u32 = 320;
    const image_height: u32 = @floatToInt(u32, @as(f32, image_width) / aspect_ratio);
    const samples_per_pixel: u32 = 100;

    //World
    const seed: u64 = 0x000000;
    var randgen = std.rand.DefaultPrng.init(seed);
    var world = try populate_2spheres(allocator);
    
    //Camera
    const cam_pos = Point3.pos(0.0, 0.0, 0.0);
    const cam_foc = Point3.pos(0.0, 0.0, 1.0);
    const cam_vh = 2.0;
    const cam_vw = aspect_ratio * cam_vh;
    const cam = Camera.init(
        cam_pos,
        cam_foc,
        cam_vh,
        cam_vw
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
            var pixel_color = Color.rgb(0, 0, 0);

            var s: usize = 0;
            while (s < samples_per_pixel) : (s+=1) {
                const u = (@intToFloat(f32, i) + common.randf(f32, randgen.random())) / dw;
                const v = (@intToFloat(f32, j) + common.randf(f32, randgen.random())) / dh; 
                var r = cam.get_ray(u, v); 
                pixel_color.addi(ray_color(&r, &world.hittable));
            }

            try color.write_color(@TypeOf(stdout), stdout, pixel_color, samples_per_pixel);
        }
    }
    try stderr.print("Done\n", .{});
}
