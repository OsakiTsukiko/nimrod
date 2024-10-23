const std = @import("std");
const fmt = std.fmt;

const zap = @import("zap");

const state = @import("./state.zig");

const webMisc = @import("./web/misc.zig");
const webListener = @import("./web/listener.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();

    state.init(allocator);
    defer state.deinit();

    std.debug.print("PK: {s}\n", .{fmt.bytesToHex(state.conf.public_key, .upper)});
    std.debug.print("SK: {s}\n", .{fmt.bytesToHex(state.conf.secret_key, .upper)});

    var l = webListener.init(allocator, 3000);
    defer l.deinit();

    l.config();
    l.start();
    
    zap.start(.{
        .threads = 2,
        .workers = 1,
    });
}