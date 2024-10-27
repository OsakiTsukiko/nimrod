const std = @import("std");
const fmt = std.fmt;
const zqlite = @import("zqlite");

const state = @import("../state.zig");

const DBUser = @import("./utils/user.zig").DBUser;



allocator: std.mem.Allocator = undefined,
database_path: [:0]u8 = undefined,
connection: zqlite.Conn = undefined,
lock: std.Thread.Mutex = undefined,



pub const Self = @This();

pub fn init(allocator: std.mem.Allocator) Self {
    const db_path = fmt.allocPrintZ(allocator, "{s}/{s}", .{state.conf.working_dir_path, state.conf.db_filename}) catch unreachable;

    const db_flags =  zqlite.OpenFlags.Create | zqlite.OpenFlags.EXResCode;
    var conn = zqlite.open(db_path, db_flags) catch unreachable; // TODO: handle?

    conn.exec(
        \\create table if not exists users (
        \\user_id integer primary key autoincrement,
        \\username text not null,
        \\passwordhash text not null,
        \\token text not null
        \\)
    , .{}) catch unreachable; // TODO: HANDLE

    // try conn.exec("insert into test (name) values (?1), (?2)", .{"Leto", "Ghanima"});

    return Self {
        .allocator = allocator,
        .database_path = db_path,
        .connection = conn,
        .lock = std.Thread.Mutex{}
    };
}

pub fn deinit(self: *Self) void {
    defer self.allocator.free(self.database_path);
    defer self.connection.close();
}

pub fn getUser(self: *Self, username: []const u8) DBUser.Errors!DBUser {
    self.lock.lock();
    defer self.lock.unlock();

    var rows = self.connection.rows("select * from users where username = (?1)", .{username}) catch unreachable;
    defer rows.deinit();
    
    // there should be only one
    if (rows.next()) |row| {
        const res = DBUser{
            .user_id = row.int(0),
            .username = row.text(1),
            .passwordhash = row.text(2),
            .token = row.text(3),
        };
        return res;
    } else {
        return DBUser.Errors.DOES_NOT_EXIST;
    }
}