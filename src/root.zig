//! Syntetica public API

const std = @import("std");
pub const rl = @import("raylib");

const log = std.log.scoped(.root);

pub const default = @import("default");
pub const config = @import("config");
pub const ecs = @import("ecs");
pub const fs = @import("fs");
pub const ui = @import("ui");
