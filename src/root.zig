//! Syntetica public API

const std = @import("std");
pub const rl = @import("raylib");
const Window = @import("Window.zig");
const ini = @import("init.zig");

pub const EngineConfig = struct {
    entity_list: ?[]const type = null,
    texture_list: ?[]const Texture.Meta = null,
    allocator: ?std.mem.Allocator = null,
};

pub fn init(title: [:0]const u8, flags: Window.WindowFlags) !void {
    _ = flags;
    ini.initWindow(title, 1200, 800);
    global.Variable.allocator = 
        @import("root")._config.allocator orelse std.heap.page_allocator;
    try ini.initManagers();
}

pub fn isRunning() bool {
    return !global.Variable.engine_should_exit;
}

pub fn getAllocator() std.mem.Allocator {
    return global.Variable.allocator;
}

pub const global = @import("global.zig");

pub fn getSettings() *@TypeOf(global.Settings) {
    return &global.Settings;
}
pub fn getKeybinds() *@TypeOf(global.Keybinds) {
    return &global.Keybinds;
}

pub const Texture = @import("Texture.zig");
pub const Frame = @import("Frame.zig");
pub const Physics = @import("Physics.zig");

/// wrapper for entity stuff for easier access.
pub const Entity = @import("Entity.zig").SyntApi(global);

/// rendering namespace for adding textures and other stuff.
pub const Renderer = @import("Renderer.zig");

pub const Shapes = @import("Shapes.zig");
pub const ActorStyle = @import("ActorStyle.zig");

pub const Data = @import("data.zig");
pub const Math = @import("math.zig");
