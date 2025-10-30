const std = @import("std");
const synt = @import("syntetica");
//const sdl3 = @import("syntetica").sdl;

pub const _config = synt.EngineConfig{
    .entity_list = &@import("entites.zig").entity_list,
};

//const ActorStyle = @import("eng/ActorStyle.zig");

pub fn main() !void {
    try synt.init("Hello syntetica!!", .{});

    const tex_path = "./src/res/test_texture.png";
    _ = tex_path;

    _ = try synt.Entity.spawn(.Player, .val(0, 0));
    
    for(0..10) |_| _ = try synt.Entity.spawn(.Enemy, .val(0, 0));

    try synt.Entity.killAll(.Enemy);

    while(synt.isRunning()){
        // logic

        try synt.Frame.start();
        defer synt.Frame.end();



        // render
    }
}
