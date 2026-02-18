const std = @import("std");

pub const alloc_size: struct {
    world: usize = 40,
} = .{};

pub var allocator: std.mem.Allocator = std.heap.page_allocator;
