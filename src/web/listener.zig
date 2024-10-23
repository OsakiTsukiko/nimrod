const std = @import("std");
const zap = @import("zap");

const misc = @import("./misc.zig");

allocator: std.mem.Allocator = undefined,
port: usize = undefined,
listener: zap.Endpoint.Listener = undefined,

pub const Self = @This();

pub fn init(allocator: std.mem.Allocator, port: usize) Self {    
    const listener = zap.Endpoint.Listener.init(
        allocator,
        .{
            .port = port,
            .on_request = misc.notFound,
            .log = true,
            .max_clients = 100000,
            // .max_body_size = 100 * 1024 * 1024,
        },
    );
    
    return Self {
        .allocator = allocator,
        .port = port,
        .listener = listener,
    };
}

pub fn deinit(self: *Self) void {
    self.listener.deinit();
}

pub fn config(self: *const Self) void {
    _ = self;
}

pub fn start(self: *Self) void {
    defer self.listener.listen() catch unreachable; // TODO: LOG ERROR
}