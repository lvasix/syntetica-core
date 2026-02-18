const std = @import("std");

const meta = @import("meta.zig");
const IR = @import("IR.zig");
const types = @import("types.zig");

const IntType = types.IntType;

fn calcPos(ir: *IR, elem: *IR.Element, offset: *IntType, pos_offset: types.Vec2) void {
    const decl = &elem.decl_ptr.shared;
    const parent_decl = if (elem.parent_id) |id| 
            &ir.tree[id].decl_ptr.shared 
        else &@TypeOf(decl.*){};

    // figure out the offset for both directions
    const offset_x = switch (parent_decl.direction) {
        .left_to_right => offset.*,
        .top_to_bottom => 0,
    };
    const offset_y = switch (parent_decl.direction) {
        .top_to_bottom => offset.*,
        .left_to_right => 0
    };

    // calculate the position
    switch(parent_decl.direction) {
        .left_to_right => {
            elem.position.x = parent_decl.padding.left + offset_x;
            elem.position.y = parent_decl.padding.top;
            elem.position.add(pos_offset);
        },
        .top_to_bottom => {
            elem.position.y = parent_decl.padding.top + offset_y;
            elem.position.x = parent_decl.padding.left;
            elem.position.add(pos_offset);
        },
    }

    // add our offset
    offset.* += switch (parent_decl.direction) {
        .left_to_right => elem.size.w,
        .top_to_bottom => elem.size.h,
    };

    var child_offset: IntType = 0;
    if(elem.which != .switch_container) {
        // iterate over children if any
        var empty = [0]IR.Element{};
        for(elem.children orelse &empty) |*child| {
            calcPos(ir, child, &child_offset, elem.position);
        }
    } else { // this element is a switch container
        calcPos(
            ir, 
            &elem.children.?[elem.data_id], 
            &child_offset,
            elem.position
        );
    }
}

fn calcSize(ir: *IR, elem: *IR.Element, offset: *IntType, largest: *IntType) void {
    const decl = &elem.decl_ptr.shared;
    const parent = &ir.tree[elem.parent_id orelse 0];
    const parent_decl = &ir.tree[elem.parent_id orelse 0].decl_ptr.shared;

    const parent_padding_x = parent_decl.padding.left + parent_decl.padding.right;
    const parent_padding_y = parent_decl.padding.top + parent_decl.padding.bottom;

    // grow elements and exact value elements need to be 
    // calculated before going to the next element (top to bottom in the tree)
    elem.size.w = switch (decl.size.w) {
        .exact_val => |val| val,
        .hook_fn => |fx| fx(elem.*),
        .grow => switch(parent_decl.size.w) {
            .grow, .exact_val, .hook_fn => switch(parent_decl.direction){
                .left_to_right => @divFloor(
                    parent.remaining_space - parent_padding_x,
                    @as(IntType, @intCast(parent.w_grow))
                ),
                .top_to_bottom => largest.* - parent_padding_y,
            },
            .fit => @panic("cannot grow into a fit container"),
        },
        else => 0,
    };
    elem.size.h = switch (decl.size.h) {
        .exact_val => |val| val,
        .hook_fn => |fx| fx(elem.*),
        .grow => switch(parent_decl.size.h) {
            .grow, .exact_val, .hook_fn => switch(parent_decl.direction){
                .top_to_bottom => @divFloor(
                    parent.remaining_space - parent_padding_y,
                    @as(IntType, @intCast(parent.h_grow))
                ),
                .left_to_right => largest.* - parent_padding_x,
            },
            .fit => @panic("cannot grow into a fit container"),
        },
        else => 0,
    };

    // handling a spacer
    if(elem.which == .spacer) {
        switch(parent_decl.direction){
            .left_to_right => elem.size.h = 0,
            .top_to_bottom => elem.size.w = 0,
        }
    }

    var child_offset: IntType = 0;
    // init the largest child to element size because this 
    // value is only really used for the grow elements and 
    // fit elements. Fit elements start with default value 
    // of 0 (for size) so it will work anyway
    var largest_child: IntType = switch(decl.direction){
        .top_to_bottom => elem.size.w,
        .left_to_right => elem.size.h,
    };
    
    var empty = [0]IR.Element{};

    if(elem.which != .switch_container) {
        // 1st pass - hook, fit and exact
        for(elem.children orelse &empty) |*child| {
            // child's grow direction relative to this element's 
            // element direction
            const child_grow_direction = switch(decl.direction) {
                .left_to_right => child.decl_ptr.shared.size.w,
                .top_to_bottom => child.decl_ptr.shared.size.h,
            };

            // do a pass on all non-grow elements
            switch(child_grow_direction) {
                .grow => continue,
                else => calcSize(ir, child, &child_offset, &largest_child),
            }
        }

        // calculate how much unused space is left for 
        // grow elements
        elem.remaining_space = switch(decl.direction){
            .left_to_right => elem.size.w - child_offset,
            .top_to_bottom => elem.size.h - child_offset,
        };

        // 2nd pass - grow elements
        for(elem.children orelse &empty) |*child| {
            // child's grow direction relative to this element's 
            // element direction
            const child_grow_direction = switch(decl.direction) {
                .left_to_right => child.decl_ptr.shared.size.w,
                .top_to_bottom => child.decl_ptr.shared.size.h,
            };

            // do a pass on all grow elements
            switch(child_grow_direction) {
                .grow => calcSize(ir, child, &child_offset, &largest_child),
                else => continue,
            }
        }
    } else { // if code path leads to this, the element must be a switch container.
        // calculate the size of the selected element/container
        elem.remaining_space = switch(decl.direction){
            .left_to_right => elem.size.w,
            .top_to_bottom => elem.size.h,
        };
        for(elem.children orelse &empty) |*child|{
            calcSize(
                ir, 
                child, 
                &child_offset, 
                &largest_child
            );
            child_offset = 0;
        }
    }

    // assign this element's children size for use 
    // in masking while drawing
    elem.children_size = .{ 
        .w = switch (decl.direction) {
            .left_to_right => child_offset,
            .top_to_bottom => largest_child,
        }, 
        .h = switch (decl.direction) {
            .left_to_right => largest_child,
            .top_to_bottom => child_offset,
        },
    };

    // element size depends on the direction
    const expand_x = switch (decl.direction) {
        .left_to_right => child_offset,
        .top_to_bottom => largest_child,
    };
    const expand_y = switch (decl.direction) {
        .top_to_bottom => child_offset,
        .left_to_right => largest_child,
    };

    // calculate the combined padding for easier use later
    const padding_x = decl.padding.left + decl.padding.right;
    const padding_y = decl.padding.top + decl.padding.bottom;

    // but fit elements need to be calculated bottom to top in the tree
    elem.size.w = switch (decl.size.w) {
        .fit => expand_x + padding_x,
        else => elem.size.w,
    };
    elem.size.h = switch (decl.size.h) {
        .fit => expand_y + padding_y,
        else => elem.size.h,
    };

    // Based on parent's grow direction
    switch(parent_decl.direction) {
        .left_to_right => {
            // add offset
            offset.* += elem.size.w;

            // check if this is the largest element
            largest.* = @max(largest.*, elem.size.h);
        },
        .top_to_bottom => {
            offset.* += elem.size.h;
            largest.* = @max(largest.*, elem.size.w);
        }
    }
}

pub fn recalculate(ir: *IR) void {
    var offset: IntType = 0;
    var largest: IntType = 0;
    calcSize(ir, &ir.tree[ir.root_id], &offset, &largest);

    offset = 0;
    calcPos(ir, &ir.tree[ir.root_id], &offset, .initScalar(0));
}
