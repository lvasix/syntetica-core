//! "meta programming" - used to define the layout in a zig-friendly way
//! (also should allow parsing of .ui.zon files in the future)

const std = @import("std");
const types = @import("types.zig");
const IntType = types.IntType;

const Sizing = union(enum) {
    pub const SizingHookFn = fn(elem: @import("IR.zig").Element) IntType;

    grow: void, // !! this needs to be here (index 0) for the compare fn to work
    fit: void,
    exact_val: IntType,

    /// this means this function will run to figure out the size
    hook_fn: *const SizingHookFn,

    pub fn exact(val: IntType) Sizing {
        return .{ .exact_val = val };
    }
    pub fn hook(fx: *const SizingHookFn) Sizing {
        return .{ .hook_fn = fx };
    }
};
pub const Size = struct {
    w: Sizing,
    h: Sizing,

    /// helper function for prettier code
    pub fn exact(w: IntType, h: IntType) Size {
        return .{
            .w = .{ .exact_val = w },
            .h = .{ .exact_val = h },
        };
    }

    /// helper function for prettier code
    pub fn fit() Size {
        return .{
            .w = .fit,
            .h = .fit,
        };
    }

    /// helper function for prettier code
    pub fn grow() Size {
        return .{
            .w = .grow,
            .h = .grow,
        };
    }

    pub fn hook(fnW: *const Sizing.SizingHookFn, fnH: *const Sizing.SizingHookFn) Size {
        return .{
            .w = .{ .hook_fn = fnW },
            .h = .{ .hook_fn = fnH },
        };
    }
};

pub const Direction = enum{
    left_to_right,
    top_to_bottom,
    // TODO: add right to left and bottom to up
};

pub const Padding = struct {
    left: IntType,
    right: IntType,
    top: IntType,
    bottom: IntType,

    pub fn padding(
        left: IntType, 
        right: IntType,
        top: IntType,
        bottom: IntType,
    ) Padding {
        return .{
            .left = left,
            .right = right,
            .top = top,
            .bottom = bottom,
        };
    }
};

pub const Element = struct {
    const Shared = struct {
        size: Size = .exact(0, 0),
        direction: Direction = .left_to_right,
        color: types.Color = types.default_color,
        padding: Padding = .padding(0, 0, 0, 0),
        uid: types.UIDType = 0,

    };

    shared: Shared,

    specific: union(enum) {
        switch_container: []const Element,
        container: []const Element,
        spacer: void, // spacer's size is determined with shared.size
        element: struct {
            which: types.Elements,
            data: types.ElementsData,
            hooks: types.ElementHook,
        }
    },

    pub fn container(data: struct {
        size: Size = .fit(),
        direction: Direction = .left_to_right,
        color: types.Color = types.default_color,
        padding: Padding = .padding(0, 0, 0, 0),
        uid: types.UIDType = 0,
        children: []const Element,
    }) Element {
        return .{
            .shared = .{
                .size = data.size,
                .direction = data.direction,
                .color = data.color,
                .padding = data.padding,
                .uid = data.uid,
            },
            .specific = .{ .container = data.children }
        };
    }

    pub fn switchContainer(data: struct {
        size: Size = .fit(),
        direction: Direction = .left_to_right,
        color: types.Color = types.default_color,
        padding: Padding = .padding(0, 0, 0, 0),
        uid: types.UIDType = 0,
        children: []const Element,
    }) Element {
        return .{
            .shared = .{
                .size = data.size,
                .direction = data.direction,
                .color = data.color,
                .padding = data.padding,
                .uid = data.uid,
            },
            .specific = .{ .switch_container = data.children }
        };
    }

    pub fn element(
        which: types.Elements,
        size: Size,
        data: anytype,
        hooks: types.ElementHook,
    ) Element {
        return .{
            .shared = .{
                .size = size,
                .direction = .left_to_right,
                .color = types.default_color,
                .uid = 0
            },
            .specific = .{
                .element = .{
                    .which = which,
                    .data = types.ElementsData.parse(which, data),
                    .hooks = hooks,
                }
            }
        };
    }

    pub fn spacer(size: Sizing) Element {
        return .{ 
            .shared = .{
                .size = .{.w = size, .h = size},
                .direction = .left_to_right,
                .color = types.default_color,
            },
            .specific = .spacer,
        };
    }
};
