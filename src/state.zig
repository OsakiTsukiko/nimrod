const std = @import("std");

const config = @import("./core/config.zig");
const db = @import("./core/db.zig");

pub var conf: config = undefined;
pub var database: db = undefined; 

pub fn init(allocator: std.mem.Allocator) void {
    conf = config.init(allocator);
    database = db.init(allocator);
}

pub fn deinit() void {
    defer conf.deinit();
    defer database.deinit();
}