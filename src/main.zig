const std = @import("std");
const synt = @import("syntetica");

pub fn main() void {
    std.debug.print("Hello syntetica!\n", .{});

    const id: synt.SyntID = synt.createTilemap();
    std.debug.print("{}\n", .{id});
}
