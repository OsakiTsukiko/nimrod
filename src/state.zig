const std = @import("std");

const config = @import("./core/config.zig");

pub var conf: config = undefined;

pub fn init(allocator: std.mem.Allocator) void {
    conf = config.init(allocator);
}

pub fn deinit() void {
    defer conf.deinit();
}