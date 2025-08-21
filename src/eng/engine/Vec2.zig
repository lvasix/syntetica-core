pub fn Vec2(T: type) type {
    return struct {
        x: T,
        y: T,

        const Self = @This();

        pub fn vec2(x: T, y: T) Self {
            return .{.x = x, .y = y};
        }
    };
}
