const std = @import("std");
const synt = @import("syntetica");

pub const _config = synt.EngineConfig{
    .entity_list = @import("entities.zig").ent_list,
    .texture_list = @import("textures.zig").textures,
};

const style_test = synt.ActorStyle.Part.body(.{
    .texture = .test_texture,
    .size = .val(100, 100),
    .form = &.{
        .leg  (.{
            .offset = .val(-70, 0),
            .texture = .placeholder,
        }),

        .leg  (.{
            .offset = .val(70, 0),
            .texture = .placeholder,
        }),
    },
});

const TestStruct = struct {
    foo: u8 = 5,
    bar: u32 = 4,
    list: [5]u8 = .{5, 3, 2, 5, 6},
};

const Renderer = synt.Renderer;

const rendapi = Renderer.RenderApi(u8, synt.Math.Vec2){
    .deinitHook = null,
    .initHook = null,
    .renderTextureFn = render,
};
const Manager = Renderer.Renderer(rendapi, 20);

fn render(texture: u8, pos: synt.Math.Vec2, size: synt.Math.Vec2, rot: f32) void {
    log.info("render: obj({}) at pos({}) with size({}), rot({})", .{
        texture, pos, size, rot
    });
}

const log = @import("std").log.scoped(.main);
fn step1RenderHook(m: *Manager, c: Manager.Chain) void {
    log.info("run: update hook on Chain({})", .{c});

    var it = m.chainIterator(c) catch |err| {
        log.err("{}, Terminating hook.", .{err});
        return;
    };

    const foo = it.next().?;
    const bar = it.next().?;
    const buzz = it.next().?;

    std.debug.print(" >> foo({})\n", .{foo});
    std.debug.print(" >> bar({})\n", .{bar});
    std.debug.print(" >> buzz({})\n", .{buzz});
}

pub fn main() !void {
    const recipe = &[_]Manager.Recipe(enum{foo, bar, buzz}){
        .head(step1RenderHook),
        .step(.foo, 4),
        .step(.bar, 2),
        .step(.buzz, 7),
    };

    var mgr = try Manager.init(synt.getAllocator());

    const chain = try mgr.createChain(recipe);
    const chain1 = try mgr.createChain(recipe);
    std.debug.print("CHAIN: {}\n", .{chain1});
    _ = chain;
//    try mgr.delChain(chain);

    const chain2 = try mgr.createChain(recipe);
    _ = chain2;

    var it = try mgr.render_queue.createIterator();
    while(it.next()) |task| {
        // switch (task.header) {
        //     .header => |h| std.debug.print("HEADER_START: {}\n", .{h}),
        //     .index => |i| std.debug.print("INDEX: {}\n", .{i}),
        // }
        std.debug.print("[{}]TASK: {}\n", .{it.current_id, task.step.tag});
    }

    try mgr.runPreRender();
    try mgr.runRender();
}

/// isolated for testing purposes
fn mainSyntetica() !void {
    try synt.init("hello", .{});

    for(style_test.form.?) |part| {
        std.debug.print("PART: {}\n", .{part});
    }

    synt.rl.setTargetFPS(30);

    while (synt.isRunning()) {
        try synt.Frame.start();
        defer synt.Frame.end();
        
        synt.rl.drawFPS(0, 0);
    }
}
