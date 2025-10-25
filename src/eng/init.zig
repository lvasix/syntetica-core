//! Initializer functions for Syntetica

const std = @import("std");
const sdl = @import("sdl3");
const global = @import("global.zig");

pub fn initTaskManager() !void {

}

pub fn initSDL() !void {
    global.Variables.sdl_init_flags = sdl.InitFlags{ .video = true };
    try sdl.init(global.Variables.sdl_init_flags);
}

pub fn initWindow(title: [:0]const u8, w: usize, h: usize) !void {
    global.Variables.sdl_default_window = 
        try sdl.video.Window.init(title, w, h, .{});

    global.Variables.sdl_fps_capper = 
        sdl.extras.FramerateCapper(f32){ .mode = .{ .limited = global.Settings.fps_cap } };
}

pub fn close() void {
    global.Variables.sdl_default_window.deinit();
    sdl.quit(global.Variables.init_flags);
}
