//! WIP, FINISH WHEN TEXTURE LOADING IS DONE!!

const api = @import("syntetica").Entity.api;
const Style = @import("syntetica").ActorStyle;

const Actor1 = struct {
    pub var data: api.Data(u8) = .{};

    // const style = Style.Part.body(.{
    //     .form = .{
    //         .head(.{
    //
    //         }),
    //     },
    // });
    //
    pub fn tick(self: api.args) void {
        _ = self;
    }
};

pub const ent_list = &[_]type{
    Actor1,
};
