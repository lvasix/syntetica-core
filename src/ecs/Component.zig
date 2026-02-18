const std = @import("std");
const Self = @This();

const Allocator = std.mem.Allocator;
const Index = usize;

pub const TableUnmanaged = struct {
    pub const empty: TableUnmanaged = .{
        .grow_capacity = 20,
        .table = .empty,
    };

    const TableType = std.ArrayListUnmanaged(Registry);

    grow_capacity: u32 = 20,
    table: TableType,

    pub fn init(allocator: std.mem.Allocator, grow_capacity: u32) !TableUnmanaged {
        return .{
            .grow_capacity = grow_capacity,
            .table = try TableType.initCapacity(allocator, grow_capacity),
        };
    }

    pub fn deinit(self: *TableUnmanaged, gpa: std.mem.Allocator) void {
        for(self.table.items) |*registry| {
            registry.deinit(gpa);
        }
        self.table.deinit(gpa);
    }

    pub fn add(self: *TableUnmanaged, gpa: Allocator, reg: Registry) !usize {
        try self.table.append(gpa, reg);
        return self.table.items.len - 1;
    }

    pub fn get(self: *TableUnmanaged, regID: Index) *Registry {
        return &self.table.items[regID];
    }

    pub fn getTyped(self: *TableUnmanaged, regID: Index, T: anytype) *TypedRegistry(T) {
        return .{
            .data = @ptrCast(@alignCast(self.table.items[regID])),
        };
    }
};

pub const Registry = struct {
    pub const empty: Registry = .{
        .grow_size = 0,
        .data_size = 0,
        .data = .empty,
    };

    pub const Iterator = struct {
        reg: *Registry,
        next_id: usize = 0,

        pub fn next(self: *Iterator) ?[]u8 {
            if(self.next_id == self.reg.data.items.len) return null;
            const data: []u8 = 
                self.reg.data.items[self.next_id..self.next_id + self.reg.data_size];
            self.next_id += self.reg.data_size;
            return data;
        }
    };
    pub fn interator(self: *Registry) Iterator {
        return .{
            .reg = self,
        };
    }

    grow_size: usize = 20,
    data_size: usize = 0,
    data: std.ArrayListUnmanaged(u8),

    pub fn initWithType(comptime T: type, grow_size: usize, gpa: Allocator) !Registry {
        return init(grow_size, @sizeOf(T), gpa);
    }

    pub fn init(grow_size: usize, data_size: usize, gpa: Allocator) !Registry {
        var self: Registry = .empty;

        self.grow_size = grow_size;
        self.data_size = data_size;

        try self.data.ensureTotalCapacity(gpa, self.grow_size * self.data_size);

        return self;
    }

    pub fn deinit(self: *Registry, gpa: Allocator) void {
        self.data.deinit(gpa);
    }

    pub inline fn ensureTotalCapacity(
        self: *Registry, 
        gpa: Allocator, 
        new_capacity: usize
    ) !void {
        return self.data.ensureTotalCapacity(gpa, new_capacity);
    }

    pub inline fn ensureFitsNItems(self: *Registry, gpa: Allocator, item_amount: usize) !void {
        return self.data.ensureTotalCapacity(
            gpa, 
            self.data.items.len + self.data_size * item_amount
        );
    }

    pub fn append(self: *Registry, gpa: Allocator, data: [*]u8) !void {
        try self.ensureTotalCapacity(gpa, self.data.items.len + self.data_size);

        return self.data.appendSliceAssumeCapacity(data[0..self.data_size]);
    }

    pub fn addOne(self: *Registry, gpa: Allocator) !usize {
        try self.ensureTotalCapacity(gpa, self.data_size);
        _ = self.data.appendNTimesAssumeCapacity(0, self.data_size);
        return self.data.items.len - self.data_size;
    }

    pub fn getSlice(self: *Registry, id: usize) []u8 {
        return self.data.items[id..id + self.data_size];
    }

    pub fn swapRemove(self: *Registry, i: usize) void {
        @memcpy(
            self.data.items[i..self.data_size], 
            self.data.items[self.data.items.len - 1 - self.data_size..]
        );

        self.data.shrinkRetainingCapacity(self.data.len - 1 - self.data_size);
    }

    pub fn memDump(self: Registry) void {
        std.debug.print("---- DUMP BEGIN ----\n", .{});

        std.debug.print("DATA SIZE: {}\n", .{self.data_size});
        std.debug.print("MEM: ", .{});
        for(self.data.items, 0..) |byte, i| {
            if(i % self.data_size == 0) std.debug.print("| ", .{});
            std.debug.print("{X:02} ", .{byte});
        }
        std.debug.print("|\n", .{});

        std.debug.print("----- DUMP END -----\n", .{});
    }
};

pub fn TypedRegistry(T: type) type {
    return struct {
        pub const Type = T;
        data: *std.ArrayListUnmanaged(T),
    };
}



// const enemy = ecs.Entity(.{.transform, .ai});
// enemy.setInitialVal(.transform, .{
//     .x = 0,
//     .y = 0,
// });
//
// ecs.instance(&enemy);
