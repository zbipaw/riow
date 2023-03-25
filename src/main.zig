const std = @import("std");

const color = @import("color.zig");
const vec3 = @import("vec3.zig");

const Color = vec3.Color;

const write_color = color.write_color;

pub fn main() !void {

    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    
    //Image
    const image_width:  u32 = 256;
    const image_height: u32 = 256;

    //Render
    std.debug.print("P3\n {d} {d}\n255\n", .{image_width, image_height});

    const dw = @as(f32, image_width - 1);
    const dh = @as(f32, image_height - 1);

    var j: isize = image_height - 1;
    while (j >= 0) : (j -= 1) {

        try stderr.print("Scanlines remaining: {}\n", .{j});

        var i: usize = 0;
        while (i < image_width) : (i += 1){

            var pixel_color = Color { @intToFloat(f32, i)/dw, @intToFloat(f32, j)/dh, 0.25 };
            try write_color(@TypeOf(stdout), stdout, pixel_color);

        }
    }

    try stderr.print("Done\n", .{});
    
}
