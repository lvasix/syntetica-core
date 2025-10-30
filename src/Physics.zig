const global = @import("global.zig");

const PhysicsEntity = struct {
    const Mobility = enum {
        rigid,
        static,
        part,
    };

    mobility: Mobility = .rigid,
    pos: global.Vec2,
};
