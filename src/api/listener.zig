// packages
const std = @import("std");
const zap = @import("zap");
// modules
const misc = @import("./misc.zig");
// endpoint modules
const public_key_endpoint = @import("./endpoints/public_key.zig");
const register_endpoint = @import("./endpoints/register.zig");

allocator: std.mem.Allocator = undefined,
port: usize = undefined,
listener: zap.Endpoint.Listener = undefined,

pk_ep: public_key_endpoint = undefined,
reg_ep: register_endpoint = undefined,

pub const Self = @This();

pub fn listen(allocator: std.mem.Allocator, port: usize) void {
    var listener = zap.Endpoint.Listener.init(
        allocator,
        .{
            .port = port,
            .on_request = misc.notFound,
            .log = true,
            .max_clients = 100000,
            // .max_body_size = 100 * 1024 * 1024,
        },
    );
    defer listener.deinit();

    var public_key_endpoint_instance = public_key_endpoint.init("/public_key");
    var register_endpoint_instance = register_endpoint.init("/register");

    listener.register(public_key_endpoint_instance.endpoint()) catch unreachable;
    listener.register(register_endpoint_instance.endpoint()) catch unreachable;

    listener.listen() catch unreachable;

    zap.start(.{
        .threads = 2,
        .workers = 1,
    });
}