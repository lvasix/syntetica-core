//! Global variables, states and settings for Syntetica engine
const Vec2i = @import("engine/Vec2.zig").Vec2(i32);
const Vec2u = @import("engine/Vec2.zig").Vec2(u32);
const Vec2 = @import("engine/Vec2.zig").Vec2(f32);

const sdl = @import("sdl2");
const Color = @import("engine/Color.zig");

pub var Settings: struct {
    screen_size: Vec2u = .vec2(0, 0),
} = .{};

pub var Variables: struct {
    sdl_window: sdl.Window,
    sdl_renderer: sdl.Renderer,
    engine_should_run: bool,
    bg_color: Color,
} = .{
    .sdl_window = undefined,
    .sdl_renderer = undefined,
    .engine_should_run = undefined,
    .bg_color = .rgb(0, 0, 0),
};
