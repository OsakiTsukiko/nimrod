const std = @import("std");
const zap = @import("zap");

const state = @import("../../state.zig");
const UserRegReq = @import("../../core/utils/user.zig").UserRegReq;

ep: zap.Endpoint = undefined,


pub const Self = @This();

pub fn init(
    path: []const u8,
) Self {
    return .{
        .ep = zap.Endpoint.init(.{
            .path = path,
            .post = post,

            .delete = not_found,
            .get = not_found,
            .patch = not_found,
            .put = not_found,
            .unauthorized = not_found,
        }),
    };
}

fn not_found(_: *zap.Endpoint, req: zap.Request) void {
    req.setStatus(.not_found);
    req.sendBody("HUH?") catch unreachable;
}

pub fn endpoint(self: *Self) *zap.Endpoint {
    return &self.ep;
}

fn post(_: *zap.Endpoint, req: zap.Request) void {
    if (req.body) |body| {
        if (std.json.parseFromSlice(
            UserRegReq,
            state.allocator,
            body,
            .{},
        )) |parsed| {
            defer parsed.deinit();

            const body_parsed = parsed.value;
            if (state.database.getUser(body_parsed.username)) |_| {
                req.sendBody("USER ALREADY EXISTS") catch unreachable;
                return;
            } else |_| {
                req.sendBody("USER NOT FOUND") catch unreachable;
                return;
            }
        } else |_| {
            std.log.err("Unable to parse reg req", .{});
        }
    } else {
        // TODO: HUH???
    }
    req.sendBody("HELLO!") catch unreachable;
}