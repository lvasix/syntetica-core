const std = @import("std");
const FreeList = @import("FreeList.zig");
const math = @import("math.zig");

const RenderHookFn: type = *const fn() void;

pub fn RenderApi(TextureType: type, Vector2: type) type {
    return struct {
        initHook: ?RenderHookFn = null,
        deinitHook: ?RenderHookFn = null,

        Texture: type = TextureType,
        Vec2: type = Vector2,

        /// function used to render a texture
        /// parameters:
        ///     Vec2i - position,
        ///     Vec2i - size,
        ///     f32 - rotation,
        ///     TextureType - texture.
        renderTextureFn: *const fn(TextureType, Vector2, Vector2, f32) void,
    };
}
// const T = enum {
//     leg, hand, body, head,
// };
//
// const recipe = &[_]Renderer.Recipe(T){
//     .head(tickfn),
//     .step(.leg, .player_leg),
//     .step(.leg, .player_leg),
//     .step(.hand, .player_hand_default),
//     .step(.hand, .player_hand_default),
//     .step(.body, .player_body),
//     .step(.head, .player_head),
// };

pub fn Renderer(conf: anytype, alloc_size: usize) type {
    return struct {
        const RenderQueue = FreeList.SimpleLinkedFreeList(Task, alloc_size);

        /// Chain just points to the first and last index of the chain
        pub const Chain = struct {
            start: usize,
            end: usize,
        };

        pub const Iterator = struct {
            renderer: *ThisRenderer,
            iterator: RenderQueue.Iterator,

            pub fn next(self: *Iterator) ?*Task {
                return self.iterator.nextPtr();
            }
        };

        /// Recipe describes how a chain behaves.
        pub fn Recipe(PartEnum: type) type {
            return struct {
                const ThisRecipe = @This();

                update_fn: ?*const fn(*ThisRenderer, Chain) void = null,
                part: PartEnum = @enumFromInt(0),
                texture: conf.Texture = undefined,

                pub fn head(fx: ?*const fn(*ThisRenderer, Chain) void) ThisRecipe {
                    return .{
                        .update_fn = fx,
                    };
                }

                pub fn step(part: PartEnum, texture: conf.Texture) ThisRecipe {
                    return .{
                        .part = part,
                        .texture = texture,
                    };
                }
            };
        }

        /// A task is a node in the queue, which describes the start of the render 
        /// chain, or a specific render task inside the chain.
        pub const Task = struct {
            header: union(enum){header: Header, index: usize},
            step: Step,
        };

        /// A header is a node in the queue that describes data about the following 
        /// N number of render steps. A header itself can carry a step.
        pub const Header = struct {
            update_fn: ?*const fn(*ThisRenderer, Chain) void,
            nodes_ahead: usize,
            chain: Chain,
        };

        /// describes what to render. Should go either after a Header, or inside the header.
        pub const Step = struct {
            obj: conf.Texture,
            pos: conf.Vec2,
            size: conf.Vec2,

            /// in radians
            rot: f32,
            tag: usize,
        };

        const ThisRenderer = @This();

        render_queue: RenderQueue = undefined,
        allocator: std.mem.Allocator = undefined,

        fn recipeToTaskSlice(
            self: *ThisRenderer, 
            recipe: anytype, 
            insertion_index: usize
        ) ![]Task {
            const task_arr = try self.allocator.alloc(Task, recipe.len - 1);

            task_arr[0] = Task{
                .header = .{.header = .{
                    .update_fn = recipe[0].update_fn,
                    .nodes_ahead = recipe.len - 2,
                    .chain = .{ .start = 0, .end = 0 }
                }},
                .step = .{
                    .obj = recipe[1].texture,
                    .tag = @intFromEnum(recipe[1].part),
                    .size = .val(0, 0),
                    .pos = .val(0, 0),
                    .rot = 0.0,
                }
            };

            for(recipe[2..], task_arr[1..]) |step, *task| {
                task.* = Task{
                    .header = .{.index = insertion_index},
                    .step = .{
                        .obj = step.texture,
                        .tag = @intFromEnum(step.part),
                        .size = .val(0, 0),
                        .pos = .val(0, 0),
                        .rot = 0.0,
                    }
                };
            }

            return task_arr;
        }

        pub fn init(allocator: std.mem.Allocator) !ThisRenderer {
            return .{
                .render_queue = try .init(allocator),
                .allocator = allocator,
            };
        }

        pub fn createChain(self: *ThisRenderer, recipe: anytype) !Chain {
            const id = self.render_queue.peekInsertionIndex();
            const slice: []Task = try self.recipeToTaskSlice(recipe, id);

            const s = try self.render_queue.insertSlice(slice);
            const inserted_slice_header = self.render_queue.getPtr(s.start);

            inserted_slice_header.header.header.chain = Chain{
                .start = s.start,
                .end = s.end,
            };

            self.allocator.free(slice);

            return .{
                .start = s.start,
                .end = s.end,
            };
        }

        pub fn delChain(self: *ThisRenderer, c: Chain) !void {
            return self.render_queue.deleteSlice(.{
                .start = c.start, 
                .end = c.end, 
                .size = 0,
            });
        }

        /// Runs pre-render tick for updating the states of steps.
        pub fn runPreRender(self: *ThisRenderer) !void {
            var it = try self.render_queue.createIterator();
            while(it.next()) |data| {
                switch (data.header) {
                    .header => |h| {
                        const fx = h.update_fn orelse continue;
                        fx(self, h.chain);
                    },
                    .index => continue,
                }
            }
        }

        pub fn runRender(self: *ThisRenderer) !void {
            var it = try self.render_queue.createIterator();
            while(it.next()) |data| {
                conf.renderTextureFn(
                    data.step.obj, 
                    data.step.pos, 
                    data.step.size, 
                    data.step.rot
                );
            }
        }

        pub fn chainIterator(self: *ThisRenderer, chain: Chain) !Iterator {
            return .{
                .renderer = self,
                .iterator = try self.render_queue.createSliceIterator(.{
                    .start = chain.start,
                    .end = chain.end,
                    .size = 0,
                }),
            };
        } 
    };
}

// pub fn RenderApi(TextureType: anytype) type {
//     return struct {
//         /// pointer to a function ran at renderer init
//         initHook: ?RenderHookFn = null,
//
//         /// pointer to a function ran at renderer deinit
//         deinitHook: ?RenderHookFn = null,
//
//         Texture: type = TextureType,
//
//         /// function used to render a texture
//         /// parameters:
//         ///     Vec2i - position,
//         ///     Vec2i - size,
//         ///     f32 - rotation,
//         ///     TextureType - texture.
//         renderTextureFn: *const fn(TextureType, Vec2i, Vec2i, f32) void,
//     };
// }
//
// pub fn Renderer(rendapi: anytype) type {
//     comptime { // check if the passed in type is correct
//         if(
//             !@hasField(@TypeOf(rendapi), "initHook") and
//             !@hasField(@TypeOf(rendapi), "deinitHook") and
//             !@hasField(@TypeOf(rendapi), "Texture") and
//             !@hasField(@TypeOf(rendapi), "renderTextureFn")
//         ) @compileError("Invalid renderer config");
//     }
//
//     return struct {
//         const ThisRenderer = @This();
//
//         /// defines what to render where
//         pub const RenderStep = struct {
//             object: rendapi.Texture,
//             pos: Vec2i,
//             size: Vec2i,
//             rot: f32,
//
//             slice: ?StepCollection = null,
//             renderStepUpdateHook: ?*const fn(*RenderStep) void = null,
//
//             pub fn step(
//                 tex: rendapi.Texture, 
//                 pos: Vec2i, 
//                 size: Vec2i, 
//                 rot: f32, 
//             ) RenderStep {
//                 return .{
//                     .object = tex,
//                     .pos = pos,
//                     .size = size,
//                     .rot = rot,
//                 };
//             }
//
//             pub fn stepFn(
//                 tex: rendapi.Texture,
//                 pos: Vec2i,
//                 size: Vec2i,
//                 rot: f32,
//                 fx: *const fn(*RenderStep) void
//             ) RenderStep {
//                 return .{
//                     .object = tex,
//                     .pos = pos,
//                     .size = size,
//                     .rot = rot,
//                     .renderStepUpdateHook = fx,
//                 };
//             }
//         };
//
//         pub const StepCollection = struct {
//             start: usize,
//             end: usize,
//         };
//
//         render_queue: FreeList.SimpleLinkedFreeList(RenderStep, 3),
//         allocator: std.mem.Allocator,
//
//         pub fn init(allocator: std.mem.Allocator) !ThisRenderer {
//             return .{
//                 .render_queue = try .init(allocator),
//                 .allocator = allocator,
//             };
//         }
//
//         pub fn deinit(self: *ThisRenderer) void {
//             self.render_queue.deinit();
//         }
//
//         pub fn addStep(self: *ThisRenderer, step: RenderStep) !usize {
//             return self.render_queue.insert(step);
//         }
//
//         pub fn addSteps(
//             self: *ThisRenderer, 
//             steps: []const RenderStep
//         ) !StepCollection {
//             const s = try self.render_queue.insertSlice(steps);
//
//             var it = try self.render_queue.createSliceterator(s);
//             while(it.next()) |_| {
//                 const data = it.getPtr();
//                 data.slice = s;
//             }
//
//             return .{
//                 .start = s.start,
//                 .end = s.end,
//             };
//         }
//
//         pub fn runRender(self: *ThisRenderer) !void {
//             var it = try self.render_queue.createIterator();
//
//             while(it.next()) |step| {
//                 const ptr = it.getPtr();
//
//                 if(step.renderStepUpdateHook == null) continue;
//
//                 step.renderStepUpdateHook.?(ptr);
//             }
//
//             try it.reset();
//
//             while(it.next()) |step| {
//                 rendapi.renderTextureFn(step.object, step.pos, step.size, step.rot);
//             }
//         }
//
//         pub fn getTextureType(self: *ThisRenderer) type {
//             _ = self;
//             return rendapi.TextureType;
//         }
//     };
// }

