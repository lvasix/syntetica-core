//! File for engine window and system window related stuff

const global = @import("global.zig");

pub const WindowFlags = struct {
    position: enum {fullscreen, windowed, centered} = .windowed,

    /// setting this to null assumes default or automatic size
    size: ?global.Vec2u = null,
};

pub const Engine = struct {

};

pub const System = struct {

};
