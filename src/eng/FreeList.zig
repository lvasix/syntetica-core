const std = @import("std");

pub fn SimpleLinkedFreeList(DataType: type, alloc_size: usize) type {
    return struct {
        const Self = @This();

        /// metadata struct for data
        const DataMeta = struct {
            prev: usize,
            next: usize,

        };

        const FreeListError = error {
            element_not_found,
            start_does_not_exist,
        };

        /// elements array
        data: []DataType = undefined,

        /// metadata for elements
        _data_info: []DataMeta = undefined,

        /// array of available elements
        _free_space: []?usize = undefined,
        
        /// First element of the linked list
        _start: ?usize = null, 
        _occupied: usize = 0,

        /// used for easier iterating over the freelist
        _compact_list: []usize = undefined,

        /// allocator
        allocator: std.mem.Allocator = undefined,

        fn checkAndResize(self: *Self) !void {
            if(!(self._occupied >= self.data.len)) return;

            self.data = try self.allocator.realloc(self.data, self.data.len + alloc_size);
            self._data_info = try self.allocator.realloc(self._data_info, self.data.len + alloc_size);
            self._free_space = try self.allocator.realloc(self._free_space, self.data.len + alloc_size);

            for(self._free_space, self._occupied..) |*data, i| {
                data.* = i;
            }
        }

        pub fn init(allocator: std.mem.Allocator) !Self {
            var obj: Self = .{};

            obj.allocator = allocator;

            obj.data = try obj.allocator.alloc(DataType, alloc_size);
            obj._data_info = try obj.allocator.alloc(DataMeta, alloc_size);
            obj._free_space = try obj.allocator.alloc(?usize, alloc_size);
            obj._compact_list = try obj.allocator.alloc(usize, 1);

            for(obj._free_space, 0..) |*data, i| {
                data.* = i;
            }

            return obj;
        }

        pub fn insert(self: *Self, data: DataType) !usize {
            try self.checkAndResize();

            const id = self._free_space[self.data.len - self._occupied - 1] orelse unreachable;
            self._free_space[self.data.len - self._occupied - 1] = null;
            self._occupied += 1;

            // linking
            if(self._start == null) {
                self._start = id;
                self._data_info[id].prev = id;
                self._data_info[id].next = id;
            } else {
                self._data_info[id].prev = self._data_info[ self._start.? ].prev; // set our last to root's last
                self._data_info[self._start.?].prev = id; // set ourselves as root's last
                self._data_info[id].next = self._start.?; // set our next to root
                self._data_info[self._data_info[id].prev].next = id; // set ourselves as our new previous' next
            }

            self.data[id] = data;

            return id;
        }

        pub fn deleteID(self: *Self, id: usize) void {
            self._free_space[self.data.len - self._occupied] = id;
            self._data_info[self._data_info[id].prev].next = self._data_info[id].next;
            self._data_info[self._data_info[id].next].prev = self._data_info[id].prev;
            self._occupied -= 1;
        }

        pub fn get(self: *Self, id: usize) DataType {
            return self.data[id];
        }

        pub fn listIDs(self: *Self) ![]usize {
            if(self._compact_list.len == self._occupied) return self._compact_list; 

            self._compact_list = try self.allocator.realloc(self._compact_list, self._occupied);
            var current_id: usize = self._start orelse return FreeListError.start_does_not_exist;

            for(self._compact_list) |*index| {
                index.* = current_id;
                current_id = self._data_info[current_id].next;
            }

            return self._compact_list;
        }

        pub fn find(self: *Self, cmp_data: DataType) !usize {
            for(try self.listIDs()) |id| {
                const data = self.get(id);
                if(std.meta.eql(data, cmp_data)) return id;
            }
            return FreeListError.element_not_found;
        }

        pub fn release(self: *Self) void {
            self.allocator.free(self.data);
            self.allocator.free(self._data_info);
            self.allocator.free(self._free_space);
            self.allocator.free(self._compact_list);
        }
    };
}
