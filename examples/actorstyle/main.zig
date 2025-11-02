const std = @import("std");
const synt = @import("syntetica");

pub const _config = synt.EngineConfig{
    .entity_list = @import("entities.zig").ent_list,
};

pub fn main() !void {
    try synt.init("hello", .{});

    var tman: synt.Texture.Manager(&(@import("textures.zig").textures)) = .init();
    const tex = try tman.getTex(.test_texture);

    std.debug.print("TEXTURE: {}", .{tex});

    while (synt.isRunning()) {

        try synt.Frame.start();
        defer synt.Frame.end();

    }
}
