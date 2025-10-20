const std = @import("std");
const synt = @import("syntetica");

// TEXTURES //////////////////
const textures = struct {
    pub const def = enum {
        air,
        undef,
        _ENDREG,
    };

    pub const path = [_][]const u8 {
        "none",
        "test/path",
    };

    pub const meta = [_]synt.Texture.MetaData{
        .{
            .render = false,
        },
        .{
            .has_transparency = true,
        },
    };
};
///////////////////////////////

pub fn main() void {
    const tx = synt.Texture.Manager(textures);

    std.debug.print("{s}\n", .{tx.getPath(.undef)});
    tx.loadAll();
    tx.unload(.undef);

    // std.debug.print("Hello syntetica!\n", .{});
    // synt.initEngine("Hello Syntetica example window", 800, 300) catch |err| {
    //     std.debug.print("E: {!}", .{err});
    // };
    //
    // synt.getKeybinds().close_app = .q;
    //
    // // Nord Frost 3
    // synt.setBgColor(.rgb(0x81, 0xa1, 0xc1));
    // while(!synt.shouldQuit()) {
    //
    //     synt.startFrame() catch unreachable;
    //     {
    //
    //     }
    //     synt.endFrame();
    // }
    //
    // const id: synt.SyntID = synt.createTilemap();
    // std.debug.print("{}\n", .{id});
}

const freelist = @import("eng/FreeList.zig");
const testing = std.testing;
test "freelist_general" {
    var fl: freelist.SimpleLinkedFreeList(u32, 5) = try .init(testing.allocator);

    for(0..10) |i| {
        const id = try fl.insert(@intCast(i));
        std.debug.print("id: {} = {}\n", .{id, i});
    }

    std.debug.print("STRUCT: {}\n", .{fl});

    std.debug.print("IDs: ", .{});
    for(try fl.listIDs()) |data_id| {
        std.debug.print("{}<-{}:{}->{} ", .{fl._data_info[data_id].prev, fl.data[data_id], data_id, fl._data_info[data_id].next});
    }
    std.debug.print("\n", .{});

    std.debug.print("DATA: ", .{});
    for(try fl.listIDs()) |data_id| {
        const data = fl.get(data_id);
        std.debug.print("{}, ", .{data});
    }
    std.debug.print("\n", .{});

    std.debug.print("{!}", .{fl.find(5)});

    fl.release();
}
