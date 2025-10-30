//! Initializer functions for Syntetica

const std = @import("std");
const rl = @import("raylib");
const global = @import("global.zig");

pub fn initTaskManager() !void {

}

pub fn initWindow(title: [:0]const u8, w: i32, h: i32) void {
    rl.initWindow(w, h, title);
}

pub fn initEntityManager() !void {
    global.Manager.entity = try @TypeOf(global.Manager.entity).init(global.Variable.allocator);
}

/// Function for making sure everything is closed correctly
pub fn close() void {
    rl.closeWindow();
}
