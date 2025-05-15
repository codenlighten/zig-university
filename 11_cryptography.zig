const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    try stdout.print("\n=== Zig Cryptography Examples ===\n\n", .{});
    
    // Example 1: Hash functions
    try stdout.print("-- Example 1: Hash Functions --\n", .{});
    try hashFunctionsExample(stdout);
    try stdout.print("\n", .{});
    
    // Example 2: HMAC (Hash-based Message Authentication Code)
    try stdout.print("-- Example 2: HMAC --\n", .{});
    try hmacExample(stdout);
    try stdout.print("\n", .{});
    
    // Example 3: Basic password hashing
    try stdout.print("-- Example 3: Basic Password Hashing --\n", .{});
    try passwordHashingExample(stdout);
    try stdout.print("\n", .{});
    
    // Example 4: Basic encryption with XOR and authentication
    try stdout.print("-- Example 4: Basic Encryption & Authentication --\n", .{});
    try basicEncryptionExample(stdout, allocator);
    try stdout.print("\n", .{});
    
    // Example 5: Random number generation
    try stdout.print("-- Example 5: Secure Random Numbers --\n", .{});
    try randomNumbersExample(stdout);
    try stdout.print("\n", .{});
    
    try stdout.print("=== End of Cryptography Examples ===\n", .{});
}

// Helper function to print byte arrays as hex
fn printHex(writer: anytype, bytes: []const u8) !void {
    for (bytes) |b| {
        try writer.print("{x:0>2}", .{b});
    }
}

// Example 1: Hash Functions (SHA-256, SHA-512, Blake2, etc.)
fn hashFunctionsExample(writer: anytype) !void {
    const message = "Hello, Zig Cryptography!";
    
    // SHA-256
    var sha256_hash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(message, &sha256_hash, .{});
    
    try writer.print("Input message: \"{s}\"\n\n", .{message});
    try writer.print("SHA-256: ", .{});
    try printHex(writer, &sha256_hash);
    try writer.print("\n", .{});
    
    // SHA-512
    var sha512_hash: [std.crypto.hash.sha2.Sha512.digest_length]u8 = undefined;
    std.crypto.hash.sha2.Sha512.hash(message, &sha512_hash, .{});
    
    try writer.print("SHA-512: ", .{});
    try printHex(writer, &sha512_hash);
    try writer.print("\n", .{});
    
    // Blake2b
    var blake2b_hash: [std.crypto.hash.blake2.Blake2b256.digest_length]u8 = undefined;
    std.crypto.hash.blake2.Blake2b256.hash(message, &blake2b_hash, .{});
    
    try writer.print("Blake2b-256: ", .{});
    try printHex(writer, &blake2b_hash);
    try writer.print("\n", .{});
    
    // Blake3
    var blake3_hash: [std.crypto.hash.Blake3.digest_length]u8 = undefined;
    std.crypto.hash.Blake3.hash(message, &blake3_hash, .{});
    
    try writer.print("Blake3: ", .{});
    try printHex(writer, &blake3_hash);
    try writer.print("\n", .{});
    
    // Incremental hashing with SHA-256
    try writer.print("\nIncremental hashing example:\n", .{});
    var sha256 = std.crypto.hash.sha2.Sha256.init(.{});
    sha256.update("Part 1 of the message: ");
    sha256.update("Part 2 of the message");
    var incremental_hash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    sha256.final(&incremental_hash);
    
    try writer.print("Incremental SHA-256: ", .{});
    try printHex(writer, &incremental_hash);
    try writer.print("\n", .{});
}

// Example 2: HMAC (Hash-based Message Authentication Code)
fn hmacExample(writer: anytype) !void {
    const message = "Message to authenticate";
    const key = "SecretHMACKey";
    
    try writer.print("Message: \"{s}\"\n", .{message});
    try writer.print("Key: \"{s}\"\n\n", .{key});
    
    // HMAC-SHA256
    var hmac_sha256: [std.crypto.auth.hmac.sha2.HmacSha256.mac_length]u8 = undefined;
    std.crypto.auth.hmac.sha2.HmacSha256.create(&hmac_sha256, message, key);
    
    try writer.print("HMAC-SHA256: ", .{});
    try printHex(writer, &hmac_sha256);
    try writer.print("\n", .{});
    
    // Manual HMAC verification (since Zig 0.14.0 doesn't have a verify function)
    var expected_hmac: [std.crypto.auth.hmac.sha2.HmacSha256.mac_length]u8 = undefined;
    std.crypto.auth.hmac.sha2.HmacSha256.create(&expected_hmac, message, key);
    const is_valid = std.mem.eql(u8, &hmac_sha256, &expected_hmac);
    try writer.print("HMAC verification: {s}\n", .{if (is_valid) "Success" else "Failure"});
    
    // Attempt to verify with wrong message
    std.crypto.auth.hmac.sha2.HmacSha256.create(&expected_hmac, "Wrong message", key);
    const is_invalid = std.mem.eql(u8, &hmac_sha256, &expected_hmac);
    try writer.print("HMAC verification with wrong message: {s}\n", .{if (is_invalid) "Success" else "Failure"});
}

// Example 3: Basic Password Hashing using SHA-256
fn passwordHashingExample(writer: anytype) !void {
    const password = "MySecurePassword123";
    
    // Generate a random salt
    var salt: [16]u8 = undefined;
    std.crypto.random.bytes(&salt);
    
    try writer.print("Password: \"{s}\"\n", .{password});
    try writer.print("Salt: ", .{});
    try printHex(writer, &salt);
    try writer.print("\n\n", .{});
    
    // Create a simple hash using SHA-256
    // In a real application, use a proper password hashing algorithm like bcrypt or Argon2
    var hash_context = std.crypto.hash.sha2.Sha256.init(.{});
    
    // Add salt to the hash
    hash_context.update(&salt);
    
    // Add password to the hash
    hash_context.update(password);
    
    // Finalize the hash
    var hash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    hash_context.final(&hash);
    
    try writer.print("Password hash (salted SHA-256): ", .{});
    try printHex(writer, &hash);
    try writer.print("\n\n", .{});
    
    // Verify the password (manually in this case)
    var verify_context = std.crypto.hash.sha2.Sha256.init(.{});
    verify_context.update(&salt);
    verify_context.update(password);
    
    var verify_hash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    verify_context.final(&verify_hash);
    
    const is_valid = std.mem.eql(u8, &hash, &verify_hash);
    try writer.print("Password verification: {s}\n", .{if (is_valid) "Success" else "Failure"});
    
    // Try with wrong password
    var wrong_context = std.crypto.hash.sha2.Sha256.init(.{});
    wrong_context.update(&salt);
    wrong_context.update("WrongPassword");
    
    var wrong_hash: [std.crypto.hash.sha2.Sha256.digest_length]u8 = undefined;
    wrong_context.final(&wrong_hash);
    
    const is_invalid = std.mem.eql(u8, &hash, &wrong_hash);
    try writer.print("Wrong password verification: {s} (as expected)\n", .{if (is_invalid) "Success" else "Failure"});
    
    // Note: This is just a simple example. In real applications,
    // always use specialized password hashing functions designed to be
    // computationally expensive (like bcrypt, scrypt, or Argon2).
}

// Example 4: Basic Encryption and Authentication
fn basicEncryptionExample(writer: anytype, allocator: std.mem.Allocator) !void {
    const message = "Top secret message that needs encryption";
    
    // Generate a random key for our stream cipher
    const key = try allocator.alloc(u8, message.len);
    defer allocator.free(key);
    std.crypto.random.bytes(key);
    
    try writer.print("Original message: \"{s}\"\n", .{message});
    try writer.print("Key: ", .{});
    try printHex(writer, key);
    try writer.print("\n\n", .{});
    
    // Create ciphertext buffer (same size as message)
    var ciphertext = try allocator.alloc(u8, message.len);
    defer allocator.free(ciphertext);
    
    // Simple XOR encryption
    for (0..message.len) |i| {
        ciphertext[i] = message[i] ^ key[i];
    }
    
    try writer.print("Encrypted: ", .{});
    try printHex(writer, ciphertext);
    try writer.print("\n", .{});
    
    // Decryption
    var decrypted = try allocator.alloc(u8, message.len);
    defer allocator.free(decrypted);
    
    // XOR again to decrypt
    for (0..message.len) |i| {
        decrypted[i] = ciphertext[i] ^ key[i];
    }
    
    try writer.print("Decrypted message: \"{s}\"\n", .{decrypted});
    
    // Add message authentication with HMAC-SHA256
    try writer.print("\nSecuring with HMAC-SHA256:\n", .{});
    
    // Generate a key for HMAC
    var hmac_key: [32]u8 = undefined;
    std.crypto.random.bytes(&hmac_key);
    
    // Calculate HMAC for the ciphertext
    var mac: [std.crypto.auth.hmac.sha2.HmacSha256.mac_length]u8 = undefined;
    std.crypto.auth.hmac.sha2.HmacSha256.create(&mac, ciphertext, &hmac_key);
    
    try writer.print("Message Authentication Code: ", .{});
    try printHex(writer, &mac);
    try writer.print("\n", .{});
    
    // Create a new HMAC to verify
    var verify_mac: [std.crypto.auth.hmac.sha2.HmacSha256.mac_length]u8 = undefined;
    std.crypto.auth.hmac.sha2.HmacSha256.create(&verify_mac, ciphertext, &hmac_key);
    const is_valid = std.mem.eql(u8, &mac, &verify_mac);
    try writer.print("HMAC verification: {s}\n", .{if (is_valid) "Success" else "Failure"});
    
    // Tamper with the ciphertext
    ciphertext[0] ^= 1;
    try writer.print("\nTampered ciphertext: ", .{});
    try printHex(writer, ciphertext);
    
    // Calculate HMAC for tampered ciphertext
    std.crypto.auth.hmac.sha2.HmacSha256.create(&verify_mac, ciphertext, &hmac_key);
    const is_invalid = std.mem.eql(u8, &mac, &verify_mac);
    try writer.print("\nHMAC verification of tampered ciphertext: {s} (as expected)\n", .{if (is_invalid) "Success" else "Failure"});
    
    // Note: This is a simplified example. In a real-world application, you would 
    // use a proper authenticated encryption algorithm that combines encryption and
    // authentication securely, such as AES-GCM or ChaCha20-Poly1305.
}

// Example 5: Secure Random Number Generation
fn randomNumbersExample(writer: anytype) !void {
    // Generate random bytes
    var random_bytes: [16]u8 = undefined;
    std.crypto.random.bytes(&random_bytes);
    
    try writer.print("Random bytes: ", .{});
    try printHex(writer, &random_bytes);
    try writer.print("\n", .{});
    
    // Generate random integers
    const random_u32 = std.crypto.random.int(u32);
    const random_i64 = std.crypto.random.int(i64);
    
    try writer.print("Random u32: {d}\n", .{random_u32});
    try writer.print("Random i64: {d}\n", .{random_i64});
    
    // Random in range
    const random_range = std.crypto.random.intRangeAtMost(u8, 1, 100);
    try writer.print("Random in range [1, 100]: {d}\n", .{random_range});
    
    // Random boolean
    const random_bool = std.crypto.random.boolean();
    try writer.print("Random boolean: {}\n", .{random_bool});
    
    // Shuffle an array
    var array = [_]u8{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    std.crypto.random.shuffle(u8, &array);
    
    try writer.print("Shuffled array: ", .{});
    for (array) |item| {
        try writer.print("{d} ", .{item});
    }
    try writer.print("\n", .{});
}
