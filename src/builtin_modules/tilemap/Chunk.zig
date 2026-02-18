const Vec2i = @import("default").Vec2i;
const Vec2u = @import("default").Vec2u;

const chunk_err = error {
    out_of_bounds_access,
};

pub fn Chunk(TileType: type, chunk_size: i64) type{
    return struct {
        pos: Vec2i,
        data: [chunk_size][chunk_size]TileType,
        
        const Self = @This();      
        
        /// init chunk at chunk grid position
        pub fn init(pos: Vec2i, d: [chunk_size][chunk_size]TileType) Self {
            const world_pos: Vec2i = .{
                .x = pos.x * chunk_size,
                .y = pos.y * chunk_size
            };
            return .{
                .pos = world_pos, 
                .data = d
            };
        }

        /// initialize a chunk with default value
        pub fn initVal(pos: Vec2i, value: TileType) Self {
            const ch_data = [_][16]TileType{
                [_]TileType{value} ** 16
            } ** 16;

            const world_pos: Vec2i = .{
                .x = pos.x * chunk_size,
                .y = pos.y * chunk_size
            };

            return .{
                .pos = world_pos,
                .data = ch_data
            };
        }

        /// get tile from chunk
        pub fn get(self: Self, pos: Vec2u) !TileType { 
            if(pos.x > chunk_size or pos.y > chunk_size) return error.out_of_bounds_access;
            return self.data[pos.x][pos.y];
        }

        /// set tile of chunk
        pub fn set(self: *Self, pos: Vec2u, t: TileType) !void {
            if(pos.x > chunk_size or pos.y > chunk_size) return error.out_of_bounds_access;
            self.data[pos.x][pos.y] = t;
        }

        pub fn fill(self: *Self, value: TileType) void {
            const ch_data = [_][16]TileType{
                [_]TileType{value} ** 16
            } ** 16;

            self.data = ch_data;
        }
    };
}

const testing = @import("std").testing;

test "init" {
    const ch_data = [_][16]u8{
        [_]u8{3} ** 16
    } ** 16;
    
    const chunk: Chunk(u8, 16) = .init(.vec2(1, -1), ch_data);
    
    try testing.expect(chunk.pos.x == 16 and chunk.pos.y == -16);
    for(chunk.data) |tilearr| {
        for(tilearr) |tile| {
            try testing.expect(tile == 3);
        }
    }
}

test "initVal" {
    const chunk: Chunk(u8, 16) = .initVal(.vec2(1, -1), 3);
    
    try testing.expect(chunk.pos.x == 16 and chunk.pos.y == -16);
    for(chunk.data) |tilearr| {
        for(tilearr) |tile| {
            try testing.expect(tile == 3);
        }
    }
}

test "get" {
    const chunk: Chunk(u8, 16) = .initVal(.vec2(0, 0), 3);

    const value: u8 = try chunk.get(.vec2(5, 10)); // testing edge cases
    const value1: u8 = try chunk.get(.vec2(16, 16));
    const value2: u8 = try chunk.get(.vec2(0, 0));

    try testing.expect(value == 3);
    try testing.expect(value1 == 3);
    try testing.expect(value2 == 3);
}

test "set" {
    var chunk: Chunk(u8, 16) = .initVal(.vec2(0, 0), 3);
    
    try chunk.set(.vec2(9, 7), 90);
    try testing.expect(chunk.data[9][7] == 90);
}

test "fill" {
    var chunk: Chunk(u8, 16) = .initVal(.vec2(0, 0), 3);
    chunk.fill(37);

    for(chunk.data) |tilearr| {
        for(tilearr) |tile| {
            try testing.expect(tile == 37);
        }
    }
}
