const std = @import("std");
const Entity = @import("syntetica").Entity;

const Player = struct {
    const DataType = struct {
        foo: bool,
        equiped_items: [4]u32 = [1]u32{0} ** 4, // placeholder
    };

    /// mandatory data field declaration
    pub var data: Entity.DataContainer(DataType) = .{};

    pub fn init(self: *Entity.fnArgs) !void {
        self.entity_data_id = try data.reqData(); 
        std.debug.print("INIT: .Player#{}\n", .{self.entityID});
    }

    pub fn tick(self: *Entity.fnArgs) void {
        data.get(self.entity_data_id).foo = true;
        std.debug.print("TICK: .Player#{}\n", .{self.entityID});
        std.debug.print("  DATA ID: {}\n", .{self.entity_data_id});
    }

    pub fn kill(self: *Entity.fnArgs) void {
        defer data.delData(self.entity_data_id);
        std.debug.print("KILL: .Player#{}\n", .{self.entityID});
        std.debug.print("  foo: {}\n", .{data.get(self.entity_data_id).foo});
        std.debug.print("  EDAID: {}\n", .{self.entity_data_id});
    }
};

const Enemy = struct {
    const DataType = struct {
        equiped_items: [4]u32 = [1]u32{0} ** 4, // placeholder
    };

    /// mandatory data field declaration
    pub var data: Entity.DataContainer(DataType) = .{};

    pub fn init(self: *Entity.fnArgs) !void {
        self.entity_data_id = try data.reqData();
        std.debug.print("INIT: .Enemy#{}\n", .{self.entityID});
    }

    pub fn tick(self: *Entity.fnArgs) void {
        std.debug.print("TICK: enemy #{}\n", .{self.entityID});
    }

    pub fn kill(self: *Entity.fnArgs) void {
        data.delData(self.entity_data_id);
        std.debug.print("KILL: .Enemy#{}\n", .{self.entityID});
    }
};

pub fn GetManager() type {
    return Entity.Manager(&.{Player, Enemy});
}
