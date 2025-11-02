//! For defining the looks of something

const Texture = struct {};

pub fn Vec2(T: type) type {
    return struct {
        x: T = 0,
        y: T = 0,

        pub fn val(x: T, y: T) @This() {
            return .{.x = x, .y = y};
        }
    };
}
pub fn vec2(x: anytype, y: @TypeOf(x)) Vec2(@TypeOf(x)) {
    return .{.x = x, .y = y};
}

pub const Part = struct {
    const Spline = struct {
        form: enum {linear, waved} = .linear,
        texture: Texture = undefined
    };

    const Class = enum {
        body, 
        leg, 
        arm, 
        head, 
        none
    };

    const Anchor = enum {
        origin,
        corner,
        none,
    };

    class: Class = .none,
    form: ?[]const Part = null,
    id: u32 = 0,
    texture: Texture = undefined,
    offset: Vec2(i32) = .val(0, 0),
    spline: ?Spline = .{},
    anchor: Anchor = .none,

    pub fn body(elem: struct {
        anchor: Anchor,
        form: []const Part,
    }) Part {
        return .{
            .class = .body,
            .anchor = elem.anchor,
            .form = elem.form,
        };
    }

    pub fn leg(elem: struct {
        id: u32 = 0,
        texture: Texture = undefined,
        offset: Vec2(i32) = .val(0, 0),
        spline: ?Spline = null,
    }) Part {
        return .{
            .class = .leg,
            .id = elem.id,
            .texture = elem.texture,
            .offset = elem.offset,
            .spline = elem.spline,
        };
    }

    pub fn arm(elem: struct {
        id: u32 = 0,
        texture: Texture = undefined,
        offset: Vec2(i32) = .val(0, 0),
        spline: ?Spline = null,
    }) Part {
        return .{
            .class = .arm,
            .texture = elem.texture,
            .id = elem.id,
            .offset = elem.offset,
            .spline = elem.spline,
        };
    }

    pub fn head(elem: struct {
        id: u32 = 0,
        anchor: Anchor,
        offset: Vec2(i32) = .val(0, 0),
    }) Part {
        return .{
            .class = .head,
            .id = elem.id,
            .anchor = elem.anchor,
            .offset = elem.offset,
        };
    }

};

pub const style = Part.body(.{
    .anchor = .none,
    .form = &.{
        .leg (.{
            .id = 0,
            .offset = .val(-2, 0),
            
            .spline = .{
                .form = .linear,
            },
        }),
        .leg (.{
            .id = 1,
            .offset = .val(2, 0),

            .spline = .{
                .form = .linear,
            },
        }),
        .arm (.{
            .id = 2,
            .offset = .val(-4, 0),
        }),
        .arm (.{
            .id = 3,
            .offset = .val(4, 0),
        }),
        .head (.{
            .id = 4,
            .anchor = .origin,
        })
    },
});

// const style = Body {
//     .class = .main,
//     .form = &.{
//         Leg {
//             .id = 0,
//             .texture = .player_leg,
//             .offset = .vec2(-2, 0),
//
//             .spline = Spline {
//                 .form = .linear,
//                 .texture = .player_spline,
//             },
//         },
//         Leg {
//             .id = 1,
//             .texture = .player_leg,
//             .offset = .vec2(2, 0),
//
//             .spline = Spline {
//                 .form = .linear,
//                 .texture = .player_spline,
//             },
//         },
//         Arm {
//             .id = 2,
//             .texture = .player_arm_default,
//             .offset = .vec2(-4, 0),
//
//             .spline = null,
//         },
//         Arm {
//             .id = 3,
//             .texture = .player_arm_default,
//             .offset = .vec2(4, 0),
//
//             .spline = null,
//         },
//         Head {
//             .texture = .player_head,
//
//             .spline = null,
//         },
//     },
// };

//style.form[4].lookat(Mouse.pos);
