const std = @import("std");
const rl = @import("raylib");
const global = @import("global.zig");

pub const Dir = struct {
    name: []const u8,
    mutable: bool = true,
};

fn getWorkingDirectoryPath() []const u8 {
    const wd = rl.getApplicationDirectory();

    return wd[0..wd.len];
}

pub fn mkDir(name: []const u8) Dir {
    std.fs.makeDirAbsolute(std.fmt.allocPrint(global.Variable.allocator, "{s}/{s}", .{getWorkingDirectoryPath(), name}));

    return .{.name = name};
}

pub fn mkFile(dir: *Dir, name: []const u8) void {
    _ = dir;
    _ = name;
}
