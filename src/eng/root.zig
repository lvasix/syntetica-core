const std = @import("std");

pub const SyntID = u32;

pub fn initEngine(win_name: []const u8, win_width: u32, win_height: u32) !void {
    _ = win_name;
    _ = win_width;
    _ = win_height;
}

pub fn createTilemap() SyntID {
    return 3;
}

const testing = std.testing;

