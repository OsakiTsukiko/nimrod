// packages
const std = @import("std");
const zap = @import("zap");
// modules
const state = @import("../../core/state/state.zig");

ep: zap.Endpoint = undefined,

pub const Self = @This();

pub fn init(
    path: []const u8,
) Self {
    return .{
        .ep = zap.Endpoint.init(.{
            .path = path,
            .get = get,
        }),
    };
}

pub fn endpoint(self: *Self) *zap.Endpoint {
    return &self.ep;
}

fn get(_: *zap.Endpoint, req: zap.Request) void {
    req.setStatus(.ok);
    const key = std.fmt.bytesToHex(state.conf.public_key, .upper);
    req.sendBody(&key) catch return;
}