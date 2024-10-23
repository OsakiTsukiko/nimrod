const std = @import("std");
const fs = std.fs;
const crypto = std.crypto;
const SigEd = crypto.sign.Ed25519;

const mycrypto = @import("./mycrypto.zig");

// TODO: technically here we don't need to save the public key
// as it can be generated from the secret key. Maybe not save it?

// Keys length in bytes
const PK_LEN: comptime_int = SigEd.PublicKey.encoded_length; // 32
const SK_LEN: comptime_int = SigEd.SecretKey.encoded_length; // 64

const PEM_PUBLIC_KEY_FILENAME = "public.key.pem";
const PEM_SECRET_KEY_FILENAME = "secret.key.pem";

allocator: std.mem.Allocator = undefined,
working_dir: fs.Dir,
working_dir_path: []u8 = undefined,
public_key: [PK_LEN]u8 = undefined,
secret_key: [SK_LEN]u8 = undefined,
keypair: SigEd.KeyPair = undefined,
db_filename: []const u8 = "data.db",
// TODO: MAYBE NOT HARDCODE THESE? LOOK FOR THEM IN std.crypto (the lengths)

pub const Self = @This();

pub fn init(allocator: std.mem.Allocator) Self {
    // setup working directory
    // get executable directory path
    const exe_dir_path = fs.selfExeDirPathAlloc(allocator) catch unreachable; // should be fine?

    // transform path to dir
    const exe_dir = fs.openDirAbsolute(
        exe_dir_path, .{.iterate = true}
    ) catch unreachable; // TODO: HANDLE ERRORS (QUIT)
    // PRAY THAT THIS DOESN'T FAIL

    var key_pair: SigEd.KeyPair = undefined;
    // key buffers
    var public_key: [PK_LEN]u8 = std.mem.zeroes([PK_LEN]u8);
    var secret_key: [SK_LEN]u8 = std.mem.zeroes([SK_LEN]u8);
    var has_pk: bool = false;
    var has_sk: bool = false;

    // open public key pem file and attempt load
    if (exe_dir.openFile(PEM_PUBLIC_KEY_FILENAME, .{})) |public_key_file| {
        defer public_key_file.close();
        _ = public_key_file.read(&public_key) catch unreachable; // TODO: HANDLE
        has_pk = true;
    } else |_| {
        std.log.err("FILE {s} DOES NOT EXIST", .{PEM_PUBLIC_KEY_FILENAME});
        // TODO: CHECK IF ERROR IS THAT FILE DOES NOT EXIST
    }

    // open secret key pem file and attempt load
    if (exe_dir.openFile(PEM_SECRET_KEY_FILENAME, .{})) |secret_key_file| {
        defer secret_key_file.close();
        _ = secret_key_file.read(&secret_key) catch unreachable; // TODO: HANDLE
        has_sk = true;
    } else |_| {
        std.log.err("FILE {s} DOES NOT EXIST", .{PEM_SECRET_KEY_FILENAME});
        // TODO: CHECK IF ERROR IS THAT FILE DOES NOT EXIST
    }

    // one of the keys does not exist
    if (!has_pk or !has_sk) {
        // regenerate key pair (and save)
        key_pair = genKeyPair(&public_key, &secret_key, exe_dir);
    } else {
        // load secret key from file
        if (SigEd.SecretKey.fromBytes(secret_key)) |secret_key_obj| {
            // create key pair from secret key
            if (SigEd.KeyPair.fromSecretKey(secret_key_obj)) |kp| {
                key_pair = kp;
                @memcpy(&public_key, &key_pair.public_key.toBytes()); // should be the same but still..
            } else |_| {
                // if fail regenerate key pair (and save)
                std.log.err("Unable to create Key Pair from Secret Key (corrupt SK), REGENERATING", .{});
                key_pair = genKeyPair(&public_key, &secret_key, exe_dir);
            }
        } else |_| {
            // if fail regenerate key pair (and save)
            std.log.err("Unable to load Secret Key, REGENERATING Key Pair");
            key_pair = genKeyPair(&public_key, &secret_key, exe_dir);
        }
    }

    // return instance of self
    return Self {
        .allocator = allocator,
        .working_dir = exe_dir,
        .working_dir_path = exe_dir_path,
        .public_key = public_key,
        .secret_key = secret_key,
    };
}

// uninitialize
pub fn deinit(self: *Self) void {
    defer self.working_dir.close();
    defer self.allocator.free(self.working_dir_path); 
    // should also free exe_dir_path from init
    // TODO: LOOK INTO THIS ^
}

fn genKeyPair(public_key: *[PK_LEN]u8, secret_key: *[SK_LEN]u8, save_dir: fs.Dir) SigEd.KeyPair {
    // generate new Sign Key Pair
    const key_pair = mycrypto.generateKeyPair();
    // copy public key into parameter
    @memcpy(public_key, &key_pair.public_key.toBytes());
    // copy secret key into parameter
    @memcpy(secret_key, &key_pair.secret_key.toBytes());
    // save to file
    writeKPFile(key_pair, save_dir);
    return key_pair;
}

fn writeKPFile(key_pair: SigEd.KeyPair, dir: fs.Dir) void {
    // create public key file
    const public_key_file = dir.createFile(
        PEM_PUBLIC_KEY_FILENAME,
        .{ .read = true, .truncate = true },
    ) catch unreachable; // TODO: HANDLE
    defer public_key_file.close();

    // write public key to file
    const pkf_wb = public_key_file.write(&key_pair.public_key.toBytes()) catch unreachable; // TODO: maybe handle?
    std.log.info("({d}) should be {d}", .{pkf_wb, PK_LEN});
    // TODO: check if pkf_wb == PK_LEN and handle

    // create secret key file
    const secret_key_file = dir.createFile(
        PEM_SECRET_KEY_FILENAME,
        .{ .read = true, .truncate = true },
    ) catch unreachable; // TODO: HANDLE
    defer secret_key_file.close();

    // write secret key to file
    const skf_wb = secret_key_file.write(&key_pair.secret_key.toBytes()) catch unreachable; // TODO: maybe handle?
    std.log.info("({d}) should be {d}", .{skf_wb, SK_LEN});
    // TODO: check if skf_wb == PK_LEN and handle
}