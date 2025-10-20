//! Initializer functions for Syntetica

const std = @import("std");
const sdl = @import("sdl3");
const global = @import("global.zig");

pub fn initTaskManager() !void {

}

pub fn initWindow(title: [:0]const u8, w: usize, h: usize) !void {
    _ = title;
    _ = w;
    _ = h;
}
