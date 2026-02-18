//! used as a config for what types the ui "library" will use 
//! not really meant to be changed
//! TODO: Maybe include an engine setting to change this stuff or something idk 

const rl = @import("raylib");
const ir = @import("IR.zig");

pub const AdditionalData = i32;
pub const IntType = i32;
pub const Color = rl.Color;
pub const Elements = enum {
    button,
    label,
};
pub const UIDType = usize;

pub const ElementsData = union(Elements) {
    button: struct {
        text: [:0]const u8 = "",
    },
    label: struct {
        text: [:0]const u8 = "",
    },

    pub fn parse(element: Elements, data: anytype) ElementsData {
        return switch(element) {
            .button => .{ .button = .{
                .text = data[0],
            }},
            .label => .{ .label = .{
                .text = data[0],
            }},
        };
    }
};

pub const hookFnPtr = *const fn(*ir) void;

pub const ElementHook = struct {
    active: ?hookFnPtr = null,
    inactive: ?hookFnPtr = null,
    updated_text: ?hookFnPtr = null,
    updated_val: ?hookFnPtr = null,
};

pub const default_color: Color = .blank;
pub const Vec2 = @import("default").Vec2.Vec2(IntType);
