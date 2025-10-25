const std = @import("std");
const global = @import("global.zig");
const sdl = @import("sdl3");

pub fn start() !void {
    global.Variables.delta_time = global.Variables.sdl_fps_capper.delay();
    
    global.Variables.sdl_window_surface = 
        try global.Variables.sdl_default_window.getSurface();
    try global.Variables.sdl_window_surface.fillRect(
        null, global.Variables.sdl_window_surface.mapRgb(128, 30, 255)
    );
    try global.Variables.sdl_default_window.updateSurface();
}

pub fn end() void {
    while (sdl.events.poll()) |event| switch (event) {
        .quit => global.Variables.engine_should_exit = true,
        .terminating => global.Variables.engine_should_exit = true,
        .key_down => |key| {
            if(global.Keybinds.close_app != null and key.key.? == global.Keybinds.close_app.?) 
                global.Variables.engine_should_exit = true;
        },
        else => {},
    };
}
