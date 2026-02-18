const Object = @This();
const world = @import("../world.zig");
const world_objects = &world.world_objects;
const world_data = &world.world_data;

pub const Traits = struct {
    /// if the object has x,y coordinates, this should be true
    positionable: union(enum){
        no,
        /// offset at which the position struct is located
        yes: usize,
    },

};

pub const Interface = struct {
    header: []anyopaque = undefined,
    data: []anyopaque = undefined,
    onInstanceFn: ?*const fn(*anyopaque, *anyopaque) void = null,
    onUpdateFn: ?*const fn(*anyopaque, *anyopaque) void = null,
    onDeleteFn: ?*const fn(*anyopaque, *anyopaque) void = null,
};

/// object interface, stores function hooks and 
/// header/data pointers as well as data size
interface: Interface,

/// stores the index at which this object's data 
/// resides inside the world_data list 
data_instance_id: usize = 0,

/// stores the size of the data in world_data list.
data_instance_size: usize = 0,

/// object traits, describes if the object can be 
/// associated with a point and more, check out the 
/// struct Traits for more info
traits: Traits = undefined,

/// initializes the object
pub fn init(interface: Interface) Object {
    return .{
        .interface = interface,
    };
}

/// creates a new object instance in world
pub fn instance(self: Object) !usize {
    // create instance in the world objects list, copying the 
    // object and getting the pointer to that object
    const obj_id = try world_objects.insert(self);
    const obj = world_objects.getPtr(obj_id);

    // reserve bytes for the object in the world data storage
    obj.data_instance_size = obj.interface.header.len + obj.interface.data.len;
    const id = try world_data.reserveBytes(obj.data_instance_size);
    // data instance id is the index our data starts at
    obj.data_instance_id = id.start;

    // assign the interface's header and data pointers
    obj.interface.header.ptr = &world_data.data[obj.data_instance_id];
    obj.interface.data.ptr = &world_data.data[obj.data_instance_size - 1];

    // run the init function on header and data, if needed
    if(obj.interface.onInstanceFn != null)
        obj.interface.onInstanceFn.?(obj.interface.header.ptr, obj.interface.data.ptr);

    // the object ID is from world_objects list, the data ID 
    // is stored inside of the world object struct
    return obj_id;
}

/// update all Objects in the world
pub fn update() !void {
    var it = try world_objects.createIterator();
    while(it.next()) |obj| {
        // some objects don't have an update function
        if(obj.interface.onUpdateFn != null)
            obj.interface.onUpdateFn.?(obj.interface.header.ptr, obj.interface.data.ptr);
    }
}

/// delete an object by ID
pub fn delete(obj_id: usize) !void {
    const obj = world_objects.getPtr(obj_id);

    // some objects don't have a delete function
    if(obj.interface.onDeleteFn != null)
        obj.interface.onDeleteFn.?(obj.interface.header.ptr, obj.interface.data.ptr);

    // construct the worldID that needs to removed, since 
    // the world doesn't actually know the type of data it stores 
    // it just sets the type to void.
    const id: @TypeOf(world_data.*).ListID(void) = .{
        .start = obj.data_instance_id,
        .size = obj.data_instance_size,
    };

    // call the delete function for world data
    try world_data.deleteID(id);

    // call the delete function for world Object
    world_objects.deleteID(obj_id);
}

