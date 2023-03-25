const std = @import("std");

pub fn main() !void {

    const stdout = std.io.getStdOut().writer();
    const stderr = std.io.getStdErr().writer();
    
    //Image

    const image_width:  u32 = 256;
    const image_height: u32 = 256;

    //Render

    std.debug.print("P3\n {d} {d}\n255\n", .{image_width, image_height});

    const mul: f32 = 255.999;
    const dw = @as(f32, image_width - 1);
    const dh = @as(f32, image_height - 1);

    var j: isize = image_height - 1;
    while (j >= 0) : (j -= 1) {

        try stderr.print("Scanlines remaining: {}\n", .{j});

        var i: usize = 0;
        while (i < image_width) : (i += 1){
            var r: f32 = @intToFloat(f32, i) / dw;
            var g: f32 = @intToFloat(f32, j) / dh;
            var b: f32 = 0.25;

            var ir = @floatToInt(u32, mul * r);
            var ig = @floatToInt(u32, mul * g);
            var ib = @floatToInt(u32, mul * b);

            try stdout.print("{d} {d} {d}\n", .{ir, ig, ib});
        }
    }
    try stderr.print("Done\n", .{});
}
