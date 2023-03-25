const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");

const Point3 = vec3.Point3;
const Ray = ray.Ray;
const Vec3 = vec3.Vec3;

const scale_vector = vec3.scale;

pub const Camera = struct {
    horizontal: Vec3,
    lower_left_corner: Point3,
    origin: Point3,
    vertical: Vec3,

    const Self = @This();

    pub fn init() Self {

        const aspect_ratio: f32 = 16.0 / 9.0;
        const focal_length: f32 = 1.0;
        const viewport_height: f32 = 2.0;
        const viewport_width: f32 = aspect_ratio * viewport_height;

        const horizontal = Vec3 { viewport_width, 0, 0 };
        const origin = Point3 { 0, 0, 0 };
        const vertical = Vec3 { 0, viewport_height, 0 };
        const lower_left_corner = (
            origin 
            - scale_vector(0.5, horizontal)
            - scale_vector(0.5, vertical)
            - Vec3{ 0, 0, focal_length }
        );

        return .{
            .origin = origin,
            .horizontal = horizontal,
            .vertical = vertical,
            .lower_left_corner = lower_left_corner,
        };       

    }

    pub fn get_ray(self: *const Self, u: f32, v: f32) Ray {

        const hor = scale_vector(u, self.horizontal);
        const ver = scale_vector(v, self.vertical);

        return .{
            .origin = self.origin,
            .direction = self.lower_left_corner + hor + ver - self.origin,
        };

    }

};
