const std = @import("std");

pub const MetaData = struct {
    render: bool = true,
    has_transparency: bool = false,
    texture_type: enum {tile, entity, item, other} = .other,
};

pub fn Manager(Registry: type) type {
    comptime { // compile time checks for struct validity.

        // check if "def" is declared
        if(!@hasDecl(Registry, "def")) @compileError("Texture registry must contain a def declaration");

        // check if "path" is declared
        if(!@hasDecl(Registry, "path")) @compileError("Texture registry must contain a path declaration");

        // check if both path and def have the same amount of elements
        if(Registry.path.len != @as(usize, @intFromEnum(Registry.def._ENDREG))) @compileError("def size and path size does not match");
    }

    // TODO: implement checks for size of path, def and meta that need to match
    return struct {
        const Self = @This();
        const largest_member: u32 = @intFromEnum(Registry.def._ENDREG);
        const tex_path: []const []const u8 = Registry.path[0..];
        
        pub fn getPath(texture: Registry.def) []const u8 {
            return tex_path[@intFromEnum(texture)];
        }

        pub fn loadAll() void {
            std.debug.print("LOAD: ALL_TEX\n", .{});
            for(tex_path) |path| {
                std.debug.print("  TEXTURE {s}...\n", .{path});
            }
            std.debug.print("DONE.\n", .{});
        }

        pub fn unload(texture: Registry.def) void {
            std.debug.print("UNLOAD: TEXTURE {}\n", .{texture});
        }
    };
}
