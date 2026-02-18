const std = @import("std");

pub const Vec2 = @import("Vec2.zig").Vec2(f32);
pub const Vec2i = @import("Vec2.zig").Vec2(i32);
pub const Vec2u = @import("Vec2.zig").Vec2(u32);

pub fn vec2(x: anytype, y: @TypeOf(x)) Vec2(@TypeOf(x)) {
    return Vec2(@TypeOf(x)).val(x, y);
}

pub const Segment = struct {
    a: Vec2,
    b: Vec2,
};

pub const Axis = Vec2;

pub fn addValueWrap(val1: anytype, val2: anytype, size: isize) @TypeOf(val1) {
    const i = val1 + val2;
    return @mod(@mod(i, size) + size, size);
}

pub fn subValueWrap(val1: anytype, val2: anytype, size: isize) @TypeOf(val1) {
    const i = val1 - val2;
    return @mod(@mod(i, size) + size, size);
}
