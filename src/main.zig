const std = @import("std");
const synt = @import("syntetica");

pub fn main() void {
    std.debug.print("Hello syntetica!\n", .{});
    synt.initEngine("Hello Syntetica example window", 800, 300) catch |err| {
        std.debug.print("E: {!}", .{err});
    };

    // Nord Frost 3
    synt.setBgColor(.rgb(0x81, 0xa1, 0xc1));
    while(!synt.shouldQuit()) {

        synt.startFrame() catch unreachable;
        {

        }
        synt.endFrame();
    }

    const id: synt.SyntID = synt.createTilemap();
    std.debug.print("{}\n", .{id});
}
