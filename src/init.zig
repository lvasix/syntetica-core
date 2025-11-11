//! Initializer functions for Syntetica

const std = @import("std");
const rl = @import("raylib");
const global = @import("global.zig");

pub fn initManagers() !void {
    global.Manager.texture = 
        try @TypeOf(global.Manager.texture).init();
    global.Manager.entity = 
        try @TypeOf(global.Manager.entity).init(global.Variable.allocator);
    global.Manager.data = 
        try @TypeOf(global.Manager.data).init(global.Variable.allocator);
}

pub fn initTaskManager() !void {

}

pub fn initWindow(title: [:0]const u8, w: i32, h: i32) void {
    rl.initWindow(w, h, title);
}

pub fn initEngine() !void {
}

pub fn initEntityManager() !void {
}

/// Function for making sure everything is closed correctly
pub fn close() void {
    rl.closeWindow();
}
