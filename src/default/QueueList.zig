const std = @import("std");

/// LIFO - Last-in, First-out
/// the last inserted element will be the first one to be taken out
pub fn QueueLIFO(QueueT: type, alloc_size: usize) type {
    return struct {
        /// the array that stores elements of the queue
        data: []QueueT,

        /// keeps track of how much of the array is occupied
        _occupied: usize,

        /// Queue's allocator
        allocator: std.mem.Allocator,

        _initialized: bool = false,

        const Self = @This();
        const QueueError = error {
            queue_empty,
        };

        /// Internal function used for resizing the Queue if so is needed.
        /// If 100% or more amount of the data array is occupied, it 
        /// resizes it by alloc_size-amount.
        ///
        /// @return error if allocation failure
        fn checkAndResize(self: *Self) !void {
            if(self._occupied < self.data.len) return; // shouldn't resize 
            
            self.data = try self.allocator.realloc(self.data, self.data.len + alloc_size);
        }

        /// Initializes the Queue.
        ///
        /// @param allocator The allocator Queue will use.
        ///
        /// @return The Queue or error if allocation failure
        ///
        /// Example
        /// ```Zig 
        /// var q: QueueLIFO(..., ...) = .init(ALLOCATOR);
        /// defer q.free(); // don't forget to free!!
        /// ```
        pub fn init(allocator: std.mem.Allocator) !Self {
            return .{
                .allocator = allocator,
                ._occupied = 0,
                .data = try allocator.alloc(QueueT, alloc_size),
                ._initialized = true
            };
        }

        /// Releases resources used by the Queue back to the system
        ///
        /// @return void 
        pub fn free(self: *Self) void {
            self.allocator.free(self.data);
            self._initialized = false;
        }

        /// Inserts an element to the top of the Queue.
        ///
        /// @param elem The element to be inserted.
        ///
        /// @return Ptr to the element inside the Queue 
        ///         or error if memory failure
        ///
        /// Example:
        /// ```Zig
        /// var q: ... = ...;
        /// defer q.free();
        ///
        /// const PTR = try q.insert(DATA_TYPE);
        /// ```
        pub fn insert(self: *Self, elem: QueueT) !*QueueT {
            try self.checkAndResize();
            self.data[self._occupied] = elem;
            self._occupied += 1;
            return &self.data[self._occupied - 1];
        }

        /// Takes (reads, removes and returns) the next element from the Queue.
        ///
        /// @return The element or error if the queue is empty
        ///
        /// Example:
        /// ```Zig
        /// var q: ... = ...;
        /// defer q.free();
        ///
        /// _ = try q.insert(5);
        /// const DATA = try q.take();
        /// // DATA == 5 here
        /// const DATA1 = try q.take(); // error, or another value if 
        ///                             // it was inserted before this call.
        /// ```
        pub fn take(self: *Self) QueueError!QueueT {
            if(self._occupied <= 0) return QueueError.queue_empty;

            self._occupied -= 1;
            const item = self.data[self._occupied];

            return item;
        }

        /// Only reads the next element from the Queue.
        ///
        /// @return The element or error if the queue is empty
        ///
        /// Example:
        /// ```Zig
        /// var q: ... = ...;
        /// defer q.free();
        ///
        /// _ = try q.insert(5);
        /// const DATA = try q.peek();
        /// // DATA == 5 here
        ///
        /// const DATA1 = try q.peek();
        /// // DATA1 == 5 here
        /// ```
        pub fn peek(self: *Self) QueueError!QueueT {
            return if(self._occupied > 0) self.data[self._occupied - 1]
                   else QueueError.queue_empty;
        }

        test "checkAndResize" {
            var q: QueueLIFO(u8, 5) = try .init(testing.allocator);
            defer q.free();

            q._occupied = 5;
            try q.checkAndResize();
            
            try testing.expectEqual(10, q.data.len);
        }
    };
}

const testing = std.testing;
test "insert" {
    var q: QueueLIFO(u8, 5) = try .init(testing.allocator);
    defer q.free();

    const ptr = try q.insert(10);
    try testing.expectEqual(10, q.data[0]);
    try testing.expectEqual(10, ptr.*);

    ptr.* = 5;
    try testing.expectEqual(5, q.data[0]);

    for(0..9) |d| {
        _ = try q.insert(@intCast(d));
    }

    try testing.expectEqual(10, q.data.len);
}

test "take" {
    var q: QueueLIFO(u8, 5) = try .init(testing.allocator);
    defer q.free();

    // trying to take out an ID in an empty Queue should return 
    // an error.
    try testing.expectError(error.queue_empty, q.take());

    _ = try q.insert(10);
    const elem = try q.take();

    // test if inserting actually inserts into the internal array
    try testing.expectEqual(10, q.data[0]);

    // test if the function correctly returns the element
    try testing.expectEqual(10, elem);

    var arr: [20]u8 = undefined;
    for(0..20) |d| {
        arr[d] = @intCast(d);
        _ = try q.insert(@intCast(d));
    }

    // need to reverse it cause it's LIFO, for FIFO it won't be reversed
    std.mem.reverse(u8, &arr);

    for(arr) |d| {
        try testing.expectEqual(d, try q.take());
    }
}

test "peek" {
    var q: QueueLIFO(u8, 5) = try .init(testing.allocator);
    defer q.free();

    // trying to take out an ID in an empty Queue should return 
    // an error.
    try testing.expectError(error.queue_empty, q.take());

    _ = try q.insert(10);
    const elem = try q.peek();

    try testing.expectEqual(10, elem);
    try testing.expectEqual(1, q._occupied);
}
