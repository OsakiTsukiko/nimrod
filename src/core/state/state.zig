// GLOBAL SINGLETON STATE

// packages
const std = @import("std");
// modules
const config = @import("./config.zig");
const db = @import("../database/database.zig");

// pseudo fields
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