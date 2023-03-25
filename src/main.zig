const std = @import("std");

const camera = @import("camera.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");
const vec3 = @import("vec3.zig");

const Camera = camera.Camera;
const Color = vec3.Color;
const Ray = ray.Ray;

const scale_vector = vec3.scale;
const unit_vector = vec3.unit;
const write_color = color.write_color;

fn ray_color(r: *const Ray) Color {

    const unit_direction = unit_vector(r.direction);

    const t = 0.5 * (unit_direction[1] + 1.0);
    const color1 = Color {1.0, 1.0, 1.0};
    const color2 = Color {0.5, 0.7, 1.0};
    const scene = scale_vector(1.0 - t, color1) + scale_vector(t, color2);

    return scene;

}

pub fn main() !void {

    //stdio
    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    
    //Image
    const _aspect_ratio: f32 = 16.0 / 9.0;
    const _image_width: u32 = 320;
    const _image_height: u32 = @floatToInt(u32, @as(f32, _image_width) / _aspect_ratio);

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
            var pixel_color = ray_color(&r);

            try write_color(@TypeOf(stdout), stdout, pixel_color);

        }

    }

    try stderr.print("Done\n", .{});

}
