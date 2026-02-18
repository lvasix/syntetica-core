const std = @import("std");
const Self = @This();

const TilemapTile = struct {
    top: u32,
    bottom: u32,
    pid: u32,
};

const TileRegistry = struct {
    textureID: u32,
    tileID: enum{},
};

pub var tiles: []TileRegistry = undefined;

pub fn registerTile() void {

}
