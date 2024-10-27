pub const DBUser = struct {
    user_id: i64,
    username: []const u8,
    passwordhash: []const u8,
    token: []const u8,

    pub const Errors = error{
        DOES_NOT_EXIST,
    };
};

pub const UserRegReq = struct { 
    username: []const u8,
    password: []const u8, 
};