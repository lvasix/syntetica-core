const std = @import("std");
const synt = @import("syntetica");
const sdl3 = @import("syntetica").sdl;

pub const _config = synt.EngineConfig{
    .entity_list = &@import("entites.zig").entity_list,
};

const ActorStyle = @import("eng/ActorStyle.zig");

pub fn main() !void {
    try synt.init("Hello syntetica!!", .{});

    const tex_path = "./src/res/test_texture.png";

    const surface = try sdl3.image.loadIo(try .initFromFile(tex_path, .read_binary), true);

    const renderer = sdl3.render.Renderer.init(synt.global.Variable.sdl_default_window, null) catch {
        std.debug.print("ERR: {s}\n", .{sdl3.errors.get() orelse "null"});
        @panic("");
    };
    try renderer.setDrawColor(.{.r = 0, .g = 0, .b = 0, .a = 0});

    const texture = try renderer.createTextureFromSurface(surface);
    surface.deinit();

    std.debug.print("{}", .{ActorStyle.style});

    _ = try synt.Entity.spawn(.Player);
    
    for(0..10) |_| _ = try synt.Entity.spawn(.Enemy);

    try synt.Entity.killAll(.Enemy);

    while(synt.isRunning()){
        // logic

        try synt.Frame.start();
        defer synt.Frame.end();

        try renderer.renderTexture(texture, null, .{.x = 0, .y = 0, .w = 50, .h = 50});
        try renderer.renderTexture(texture, null, .{.x = 400, .y = 0, .w = 50, .h = 50});
        try renderer.renderTexture(texture, null, .{.x = 0, .y = 400, .w = 50, .h = 50});
        try renderer.renderTexture(texture, null, .{.x = 200, .y = 200, .w = 50, .h = 50});

//        try renderer.renderDebugText(.{.x = 100, .y = 0}, "Checking if this will flicker too");

        try renderer.present();

        try renderer.clear();

        // render
    }
}
