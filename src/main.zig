const std = @import("std");

const camera = @import("camera.zig");
const color = @import("color.zig");
const common = @import("common.zig");
const ray = @import("ray.zig");
const objects = @import("objects.zig");
const tup3 = @import("tup3.zig");

const Allocator = std.mem.Allocator;
const Camera = camera.Camera;
const Color = tup3.Color;
const HitRecord = objects.HitRecord;
const Hittable = objects.Hittable;
const HittableList = objects.HittableList;
const Point3 = tup3.Point3;
const Ray = ray.Ray;
const Sphere = objects.Sphere;
const Vec3 = tup3.Vec3;

fn two_spheres(allocator: Allocator) !HittableList {
    const sphere1 = try allocator.create(Sphere);
    sphere1.* = Sphere.init(Point3.pos(0, 0, -1), 0.5);
    const sphere2 = try allocator.create(Sphere);
    sphere2.* = Sphere.init(Point3.pos(0, -100.5, -1), 100);

    var world = HittableList.init(allocator);
    try world.add(&sphere1.hittable);
    try world.add(&sphere2.hittable);
    return world;
}

fn ray_color(r: Ray, world: *Hittable, depth: u32) Color {
    var hitrec: HitRecord = undefined;

    // If we've exceeded the ray bounce limit, no more light is gathered.
    if (depth <= 0) return Color.rgb(0.0, 0.0, 0.0);
    
    if (world.hit(r, common.e, common.inf, &hitrec)) {
        const target = hitrec.p.add(tup3.rand_ihemi(hitrec.normal));
        return ray_color(
            Ray.new(hitrec.p, target.sub(hitrec.p)),
            world,
            depth - 1
        ).mul(0.5);
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
    const aspect_ratio: f32 = 16.0 / 9.0;
    const image_width: u32 = 320;
    const image_height: u32 = @floatToInt(u32, @as(f32, image_width) / aspect_ratio);
    const max_depth: u32 = 50; 
    const samples_per_pixel: u32 = 100;

    //World
    var world = try two_spheres(allocator);
    
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
