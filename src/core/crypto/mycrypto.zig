const std = @import("std");
const crypto = std.crypto;
const sign = crypto.sign;
const SigEd = sign.Ed25519;

pub fn generateKeyPair() SigEd.KeyPair {
    // generate a random Ed25519 key pair, public key: 32 bytes secret key: 64 bytes
    // keys should be reusable // TODO: LOOK INTO THIS <<<
    const kp = SigEd.KeyPair.create(null) catch unreachable; // TODO: HANDLE
    return kp;
}

    // var seed: [Ed25519.KeyPair.seed_length]u8 = undefined;
    // var ran_sum = std.Random.DefaultPrng.init(0);
    // ran_sum.fill(&seed);

    // const kp = Ed25519.KeyPair.create(null) catch unreachable;
    // const pkb = kp.public_key.toBytes();
    // const skb = kp.secret_key.toBytes();
    // std.debug.print("PK: ", .{});
    // for (pkb) |b| {
    //     std.debug.print("{X}", .{b});
    // }
    // std.debug.print("\n", .{});
    // std.debug.print("SK: ", .{});
    // for (skb) |b| {
    //     std.debug.print("{X}", .{b});
    // }
    // std.debug.print("\n", .{});

    // const sig = kp.sign("test_1", null) catch unreachable;
    // const sigb = sig.toBytes();
    // const idk = fmt.bytesToHex(sigb, .upper);
    // std.debug.print("BRUV: {s}\n", .{idk});
    // try sig.verify("test_1", kp.public_key);