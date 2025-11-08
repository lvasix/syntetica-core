const std = @import("std");
const synt = @import("syntetica");

pub const _config = synt.EngineConfig{
    .entity_list = @import("entities.zig").ent_list,
    .texture_list = @import("textures.zig").textures,
};

const style_test = synt.ActorStyle.Part.body(.{
    .form = &.{
        .head (.{
            .texture = .test_texture,
        }),
    },
});

const TestStruct = struct {
    foo: u8 = 5,
    bar: u32 = 4,
    list: [5]u8 = .{5, 3, 2, 5, 6},
};

pub fn main() !void {
    try synt.init("hello", .{});

    const texture = try synt.global.Manager.texture.getTex(.test_texture);
    std.debug.print("TEXTURE: {}\n", .{texture});

    for(style_test.form.?) |part| {
        std.debug.print("PART: {}\n", .{part});
    }

    while (synt.isRunning()) {

        try synt.Frame.start();
        defer synt.Frame.end();

    }
}
