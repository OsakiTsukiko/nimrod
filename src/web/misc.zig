const std = @import("std");
const zap = @import("zap");

pub fn notFound(req: zap.Request) void {
    req.sendBody("404 Not found") catch return;
}