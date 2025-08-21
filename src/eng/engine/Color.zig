const Self = @This();

/// Red
r: u8,

/// Green
g: u8,

/// Blue
b: u8,

/// Alpha
a: u8,

pub fn rgb(r: u8, g: u8, b: u8) Self {
    return .{.r = r, .g = g, .b = b, .a = 255};
}

pub fn rgba(r: u8, g: u8, b: u8, a: u8) Self {
    return .{.r = r, .g = g, .b = b, .a = a};
}
