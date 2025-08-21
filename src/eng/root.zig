//! Syntetica public API

const std = @import("std");
const sdl = @import("sdl2");
const global = @import("global.zig");

pub const Color = @import("engine/Color.zig");
pub const SyntID = u32;

const INI = @import("init.zig");
/// Initializes the engine window and all features
pub fn initEngine(win_name: [:0]const u8, win_width: u32, win_height: u32) !void {
    try sdl.init(.{
        .video = true,
        .events = true,
        .audio = true,
    });

    try INI.initWindow(win_name, win_width, win_height);
}

/// call after intializing the engine, deinits the engine
pub fn exitEngine() void {
    global.Variables.sdl_window.destroy();
    sdl.quit(); // exit sdl, should go last
}

pub fn setBgColor(c: Color) void {
    global.Variables.bg_color = c;
}

pub fn shouldQuit() bool {
    return global.Variables.engine_should_run;
}

pub fn startFrame() !void {
    const gvar = global.Variables;
    try gvar.sdl_renderer.setColorRGB(gvar.bg_color.r, gvar.bg_color.g, gvar.bg_color.b);
    try gvar.sdl_renderer.clear();
}

pub fn endFrame() void {
    global.Variables.sdl_renderer.present();
}

/// creates a new Tilemap object and returns the index I guess
pub fn createTilemap() SyntID {
    return 3;
}

const testing = std.testing;

