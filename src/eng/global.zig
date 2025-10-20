//! Global variables, states and settings for Syntetica engine
const Vec2i = @import("Vec2.zig").Vec2(i32);
const Vec2u = @import("Vec2.zig").Vec2(u32);
const Vec2 = @import("Vec2.zig").Vec2(f32);

const std = @import("std");
const sdl = @import("sdl2");
const Color = @import("Color.zig");
const Tile = @import("tile.zig");
const chunk_size: comptime_int = 16;

pub const TilemapType = @import("libTilemap.zig").Tilemap(Tile, chunk_size);

pub var Settings: struct {
    screen_size: Vec2u = .vec2(0, 0),
} = .{};

pub var Variables: struct {
    sdl_window: sdl.Window = undefined,
    sdl_renderer: sdl.Renderer = undefined,
    engine_should_run: bool = true,
    bg_color: Color = .rgb(0, 0, 0),
    tilemap: TilemapType = undefined,
    allocator: std.mem.Allocator = undefined,
    debugging: bool = false,
} = .{};

pub var keybinds: struct {
    /// keybind for closing the main app. if null, no keybind is used and it is up to the 
    /// app to handle closing.
    close_app: ?sdl.keycode = .q,
} = .{};
