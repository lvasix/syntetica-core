//! Syntetica public API

const std = @import("std");
const sdl = @import("sdl3");

pub const global = @import("global.zig");
const ini = @import("init.zig");
//pub const Texture = @import("textures/texManager.zig");
//const res = @import("resource_interface.zig");

const testing = std.testing;

pub fn init() !void {
    
}

/// Texture namespace for texture management
pub const Texture = @import("texManager.zig");
