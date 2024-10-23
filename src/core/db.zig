const std = @import("std");
const fmt = std.fmt;

const zqlite = @import("zqlite");

const state = @import("../state.zig");

allocator: std.mem.Allocator = undefined,
database_path: []u8 = undefined,
connection: zqlite.Conn = undefined,

pub const Self = @This();

pub fn init(allocator: std.mem.Allocator) Self {
    const db_path = fmt.allocPrintZ(allocator, "{s}/{s}", .{state.conf.working_dir_path, state.conf.db_filename}) catch unreachable;

    const db_flags =  zqlite.OpenFlags.Create | zqlite.OpenFlags.EXResCode;
    var conn = zqlite.open(db_path, db_flags) catch unreachable; // TODO: handle?

    conn.exec(
        \\CREATE TABLE IF NOT EXISTS users (
        \\id INTEGER PRIMARY KEY AUTOINCREMENT,
        \\username TEXT NOT NULL,
        \\passwordhash TEXT NOT NULL,
        \\token TEXT NOT NULL
        \\)
    , .{}) catch unreachable; // TODO: HANDLE

    // try conn.exec("insert into test (name) values (?1), (?2)", .{"Leto", "Ghanima"});

    return Self {
        .allocator = allocator,
        .database_path = db_path,
        .connection = conn,
    };
}

pub fn deinit(self: *Self) void {
    defer self.allocator.free(self.database_path);
    defer self.connection.close();
}