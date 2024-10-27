// packages
const std = @import("std");
const fmt = std.fmt;
const zap = @import("zap");
const zqlite = @import("zqlite");
// modules
const state = @import("./core/state/state.zig");
const api_misc = @import("./api/misc.zig");
const api_listener = @import("./api/listener.zig");



pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .thread_safe = true,
    }){};
    const allocator = gpa.allocator();

    var args = std.process.args(); // command line arguments
    var port: usize = 3000; // default port 3000
    
    if (args.skip()) {
        const port_string = args.next(); // get port argument
        if (port_string) |port_string_nn| { // ignore null
            if (fmt.parseInt(usize, port_string_nn, 10)) |prs_res| { // parse arg as int
                port = prs_res;
            } else |_| {}
        }
    }
    

    state.init(allocator);
    defer state.deinit();

    std.debug.print("PK: {s}\n", .{fmt.bytesToHex(state.conf.public_key, .upper)});
    std.debug.print("SK: {s}\n", .{fmt.bytesToHex(state.conf.secret_key, .upper)});

    api_listener.listen(allocator, port);    
}