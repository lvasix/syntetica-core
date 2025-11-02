const synt = @import("syntetica");

pub const textures = [_]synt.Texture.Meta{
    .tex("test_texture", "test_texture.png", .setType(.entity)),
};
