//! Initializer functions for Syntetica

const std = @import("std");
const sdl = @import("sdl2");
const global = @import("global.zig");

pub fn initWindow(title: [:0]const u8, w: usize, h: usize) !void {
    global.Variables.sdl_window = try sdl.createWindow(
        title,
        .{.centered = {}}, .{.centered = {}},
        w, h,
        .{.vis = .shown},
    );

    global.Variables.sdl_renderer = try sdl.createRenderer(
        global.Variables.sdl_window, 
        null,
        .{.accelerated = true},
    );
}
