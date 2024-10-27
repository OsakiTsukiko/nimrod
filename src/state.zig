const std = @import("std");

const config = @import("./core/config.zig");
const db = @import("./core/db.zig");

pub var conf: config = undefined;
pub var database: db = undefined; 
pub var allocator: std.mem.Allocator = undefined;

pub fn init(alloc: std.mem.Allocator) void {
    conf = config.init(alloc);
    database = db.init(alloc);
    allocator = alloc;
}

pub fn deinit() void {
    defer conf.deinit();
    defer database.deinit();
}