const std = @import("std");
const zap = @import("zap");

const misc = @import("./misc.zig");

const public_key_endpoint = @import("./endpoints/public_key.zig");

allocator: std.mem.Allocator = undefined,
port: usize = undefined,
listener: zap.Endpoint.Listener = undefined,

pk_ep: public_key_endpoint = undefined,

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
        .pk_ep = public_key_endpoint.init("/public_key"),
    };
}

pub fn deinit(self: *Self) void {
    self.listener.deinit();
}

pub fn config(self: *Self) void {
    self.listener.register(self.pk_ep.endpoint()) catch unreachable; // TODO: handle?
}

pub fn start(self: *Self) void {
    defer self.listener.listen() catch unreachable; // TODO: LOG ERROR
}