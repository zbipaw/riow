const vec3 = @import("vec3.zig");

const Color = vec3.Color;

pub fn write_color(comptime WriterType: type, out: WriterType, pixel_color: Color) !void {

    var r = pixel_color[0];
    var g = pixel_color[1];
    var b = pixel_color[2];

    // Write the translated [0,255] value of each color component.
    const mul: f32 = 255.999;

    const ir: u32 = @floatToInt(u32, mul * r);
    const ig: u32 = @floatToInt(u32, mul * g);
    const ib: u32 = @floatToInt(u32, mul * b);
    
    try out.print("{} {} {}\n", .{ ir, ig, ib });

}
