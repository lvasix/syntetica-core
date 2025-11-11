const std = @import("std");
const rl = @import("raylib");
const global = @import("global.zig");
//const DataManager = @This();

pub fn DataManager(prefix: []const u8) type {
    return struct {
        const Meta = struct {
            collection_num: u32 = 0, // 10 digits
            file_num: u32 = 0, // 10 digits
            largest_name: u32 = 0,
        };

        const ThisMgr = @This();
        const conf_file_name: []const u8 = ".conf.zon";

        allocator: std.mem.Allocator = std.heap.page_allocator,
        exe_dir_path: []const u8 = undefined,
        zon_buf: []u8 = undefined,

        meta: Meta = .{},

        prefix_dir: std.fs.Dir = undefined,
        meta_file: std.fs.File = undefined,

        fn getMetaSize() usize {
            var len: u32 = 0;

            for(std.meta.fieldNames(Meta)) |name| {
                len += @intCast(name.len);
                len += 10; // the number 
                len += 6; // the ".", "=", "," and three spaces
            }
            len += 10; // for the .{ ... }

            return len;
        }

        fn updateMeta(self: *ThisMgr) !void {
            try self.meta_file.seekTo(0);
            var writer = self.meta_file.writer(self.zon_buf).interface;
            defer @memset(self.zon_buf, 0);

            try std.zon.stringify.serialize(self.meta, .{.whitespace = false}, &writer);

            const index = std.mem.indexOf(u8, self.zon_buf, "\x00") orelse self.zon_buf.len - 1;

            _ = try self.meta_file.write(self.zon_buf[0..index]);
        }

        fn loadMeta(self: *ThisMgr) !void {
            try self.meta_file.seekTo(0);
            const read_bytes = try self.meta_file.read(self.zon_buf);
            defer @memset(self.zon_buf, 0);

            const buf_sentiel = try self.allocator.dupeZ(u8, self.zon_buf[0..read_bytes]);
            defer self.allocator.free(buf_sentiel);

            const meta = try std.zon.parse.fromSlice(Meta, self.allocator, buf_sentiel, null, .{});

            self.meta = meta;
        }

        fn initPrefixMeta(self: *ThisMgr) !void {
            // get the executable's directory path instead of using the cwd

            var was_initialized: bool = false;
            self.meta_file = self.prefix_dir.openFile(conf_file_name, .{.mode = .read_write}) catch |err| create_file: {
                if(err == error.FileNotFound){
                    std.debug.print("ERROR: file not found, creating new.\n", .{});
                    was_initialized = true;
                    break :create_file try self.prefix_dir.createFile(conf_file_name, .{.read = true});
                } else return err;
            };

            self.meta = .{
                .file_num = 0,
                .collection_num = 0,
            };

            self.zon_buf = try self.allocator.alloc(u8, getMetaSize());
            @memset(self.zon_buf, 0);

            if(!was_initialized) {
                try self.loadMeta();
                return;
            }

            try self.updateMeta();

            @memset(self.zon_buf, 0);
        }

        pub fn init(allocator: std.mem.Allocator) !ThisMgr {
            var obj = ThisMgr{
                .allocator = allocator,
                .exe_dir_path = try std.fs.selfExeDirPathAlloc(allocator),
            };

            const prefix_path = 
                if(prefix[0] == ':') 
                    try std.mem.concat(allocator, u8, &.{obj.exe_dir_path, "/", prefix[1..]}) 
                else 
                    try std.fmt.allocPrint(allocator, "{s}", prefix);

            std.debug.print("EXE DIR: {s}\n", .{obj.exe_dir_path});
            std.debug.print("GEN PREFIX PATH: {s}\n", .{prefix_path});

            obj.prefix_dir = std.fs.openDirAbsolute(prefix_path, .{.iterate = true}) catch |err| create_file:{
                if(err == error.FileNotFound) {
                    try std.fs.makeDirAbsolute(prefix_path);
                    break :create_file try std.fs.openDirAbsolute(prefix_path, .{});
                    
                } else return err;
            };

            allocator.free(prefix_path);

            try obj.initPrefixMeta();

            return obj;
        }

        pub fn createObj(self: *ThisMgr, comptime name: []const u8) !void {
            if(try self.objExists(name ++ ".zon")) return;

            self.meta.file_num += 1;
            try self.updateMeta();

            const f = try self.prefix_dir.createFile(name ++ ".zon", .{});
            defer f.close();
        }

        pub fn objExists(self: *ThisMgr, comptime name: []const u8) !bool {
            const f = self.prefix_dir.openFile(name ++ ".zon", .{}) catch |err| {
                if(err == error.FileNotFound) return false
                else return err;
            };
            defer f.close();

            return true;
        }

        pub fn writeObj(self: *ThisMgr, comptime name: []const u8, data: anytype) !void {
            const f = try self.prefix_dir.openFile(name ++ ".zon", .{.mode = .read_write});
            defer f.close();

            const data_string = try std.fmt.allocPrint(self.allocator, "{}", .{data});
            defer self.allocator.free(data_string);

            std.debug.print("DATA: {s}\n", .{data_string});
            std.debug.print(" >> LEN: {}\n", .{data_string.len});

            const buf = try self.allocator.alloc(u8, data_string.len + 20);
            @memset(buf, 0);
            defer self.allocator.free(buf);

            var writer = f.writer(buf).interface;

            try std.zon.stringify.serialize(data, .{.whitespace = false}, &writer);
            const index = std.mem.indexOf(u8, buf, "\x00") orelse buf.len - 1;
            std.debug.print("INDEX: {}\n", .{index});

            _ = try f.write(buf[0..index]);
        }

        pub fn loadObj(self: *ThisMgr, comptime name: []const u8, T: type) !T {
            const f = try self.prefix_dir.openFile(name ++ ".zon", .{ .mode = .read_only });
            defer f.close();

            const lenght = try f.getEndPos();

            const buf = try self.allocator.allocSentinel(u8, lenght, 0);
            @memset(buf, 0);
            defer self.allocator.free(buf);

            _ = try f.read(buf);

            const obj = std.zon.parse.fromSlice(T, self.allocator, buf, null, .{});

            return obj;
        }

        pub fn getFilePath(self: *ThisMgr, name: []const u8) ![]const u8 {
            const path = try self.prefix_dir.realpathAlloc(self.allocator, ".");
            defer self.allocator.free(path);

            return try std.mem.concat(self.allocator, u8, &.{path, "/", name});
        }

        pub fn listPaths(self: *ThisMgr) ![]const []const u8 {
            var stats: u32 = 0;
            var it = self.prefix_dir.iterate();
            while(try it.next()) |_| {
                stats += 1;
            }
            const paths: [][]const u8 = try self.allocator.alloc([]const u8, stats);

            it.reset();
            var i: u32 = 0;
            while(try it.next()) |entry| : (i += 1) {
                paths[i] = try self.allocator.dupe(u8, entry.name);
            }

            return paths;
        }

        pub fn clrListedPaths(self: *ThisMgr, p: []const []const u8) void {
            for(p) |s| {
                self.allocator.free(s);
            }
            self.allocator.free(p);
        }

        pub fn Collection(comptime col_name: []const u8) type {
            return struct {
                const ThisCollection = @This();

                name: []const u8 = col_name,

                mgr: DataManager(prefix ++ "/" ++ col_name) = undefined,

                pub fn init(allocator: std.mem.Allocator) !ThisCollection {
                    return .{
                        .mgr = try .init(allocator)
                    };
                }

                pub fn createObj(self: *ThisCollection, comptime name: []const u8) !void {
                    try self.mgr.createObj(name);
                }

                pub fn objExists(self: *ThisCollection, comptime name: []const u8) !bool {
                    return self.mgr.objExists(name);
                }

                pub fn writeObj(self: *ThisCollection, comptime name: []const u8, data: anytype) !void {
                    try self.mgr.writeObj(name, data);
                }

                pub fn loadObj(self: *ThisCollection, comptime name: []const u8, T: type) !T {
                    return self.mgr.loadObj(name, T);
                }

                pub fn getFilePath(self: *ThisCollection, name: []const u8) ![]const u8 {
                    return self.mgr.getFilePath(name);
                }

                pub fn createCollection(comptime new_col_name: []const u8) type {
                    return Collection(new_col_name);
                }

                pub fn remove(self: *ThisCollection) !void {
                    try self.mgr.prefix_dir.deleteDir("");
                }

                pub fn deinit(self: *ThisCollection) void {
                    self.mgr.deinit();
                }
            };
        }

        pub fn deinit(self: *ThisMgr) void {
            self.allocator.free(self.exe_dir_path);
            self.allocator.free(self.zon_buf);
            self.prefix_dir.close();
            self.meta_file.close();
        }
    };
}
