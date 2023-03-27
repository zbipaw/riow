const common = @import("common.zig");
const tup3 = @import("tup3.zig");

const Color = tup3.Color;

pub fn write_color(comptime WriterType: type, out: WriterType, pixel_color: Color, samples_per_pixel: i32) !void {
    var r = pixel_color.x;
    var g = pixel_color.y;
    var b = pixel_color.z;

    // Divide the color by the number of samples.
    const scale = 1.0 / @intToFloat(f32, samples_per_pixel);
    r *= scale;
    g *= scale;
    b *= scale;

    const ir: u32 = @floatToInt(u32, 256 * common.clamp(f32, r, 0.0, 0.999));
    const ig: u32 = @floatToInt(u32, 256 * common.clamp(f32, g, 0.0, 0.999));
    const ib: u32 = @floatToInt(u32, 256 * common.clamp(f32, b, 0.0, 0.999));
    
    try out.print("{} {} {}\n", .{ ir, ig, ib });
}
