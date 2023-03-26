const std = @import("std");

const camera = @import("camera.zig");
const color = @import("color.zig");
const common = @import("common.zig");
const ray = @import("ray.zig");
const objects = @import("objects.zig");
const vec3 = @import("vec3.zig");

const Camera = camera.Camera;
const Color = vec3.Color;
const HitRecord = objects.HitRecord;
const Hittable = objects.Hittable;
const HittableList = objects.HittableList;
const Point3 = vec3.Point3;
const Ray = ray.Ray;
const Sphere = objects.Sphere;
const Vec3 = vec3.Point3;

fn ray_color(r: *Ray, world: *Hittable) Color {
    var rec: HitRecord = undefined;
    if (world.hit(r, common.e, common.inf, &rec)) return vec3.scale(0.5, rec.normal + Color {1, 1, 1});
    
    const unit_direction = vec3.unit(r.direction);
    const t: f32 = 0.5 * (unit_direction[1] + 1.0);

    const color1 = Color {1.0, 1.0, 1.0};
    const color2 = Color {0.5, 0.7, 1.0};
    const scene = vec3.scale(1.0 - t, color1) + vec3.scale(t, color2);

    return scene;
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
    const _aspect_ratio: f32 = 16.0 / 9.0;
    const _image_width: u32 = 320;
    const _image_height: u32 = @floatToInt(u32, @as(f32, _image_width) / _aspect_ratio);

    //World
    var world = HittableList.init(allocator);

    const sphere1 = try allocator.create(Sphere);
    const sphere2 = try allocator.create(Sphere);
    sphere1.* = Sphere.init(Point3 {0, 0, -1}, 0.5);
    sphere2.* = Sphere.init(Point3 {0, -100.5, -1}, 100);
    try world.add(&sphere1.hittable);
    try world.add(&sphere2.hittable);

    //Camera
    const _camera = Camera.init();

    //Render
    try stdout.print("P3\n{d} {d}\n255\n", .{_image_width, _image_height});

    const dw = @as(f32, _image_width - 1);
    const dh = @as(f32, _image_height - 1);

    var j: isize = _image_height - 1;
    while (j >= 0) : (j -= 1) {
        try stderr.print("Scanlines remaining: {}\n", .{j});

        var i: usize = 0;
        while (i < _image_width) : (i += 1) {
            const u = @intToFloat(f32, i) / dw;
            const v = @intToFloat(f32, j) / dh;    

            var r = _camera.get_ray(u, v);
            var pixel_color = ray_color(&r, &world.hittable);

            try color.write_color(@TypeOf(stdout), stdout, pixel_color);
        }
    }
    try stderr.print("Done\n", .{});
}
