pub fn Vec2(T: type) type {
    return struct {
        x: T,
        y: T,

        const Self = @This();

        pub fn val(x: T, y: T) Self {
            return .{.x = x, .y = y};
        }
    };
}

pub fn vec2(x: anytype, y: @TypeOf(x)) Vec2(@TypeOf(x)) {
    return Vec2(@TypeOf(x)).val(x, y);
}
