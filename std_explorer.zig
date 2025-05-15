const std = @import("std");

// This function prints out some important modules in the standard library
// and examples of functions within them
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("\n=== Zig Standard Library Explorer ===\n\n", .{});

    // 1. Memory and Allocation
    try stdout.print("-- Memory and Allocation --\n", .{});
    try stdout.print("std.mem: Memory manipulation functions\n", .{});
    try stdout.print("std.heap: Various allocator implementations\n", .{});
    try stdout.print("  * page_allocator: Simple page allocator\n", .{});
    try stdout.print("  * c_allocator: Thin wrapper around libc malloc/free\n", .{});
    try stdout.print("  * ArenaAllocator: Frees all memory at once\n", .{});
    try stdout.print("  * GeneralPurposeAllocator: Production-grade allocator\n\n", .{});

    // 2. Data Structures
    try stdout.print("-- Data Structures --\n", .{});
    try stdout.print("std.ArrayList: Dynamic array\n", .{});
    try stdout.print("std.StringHashMap: Hash map with string keys\n", .{});
    try stdout.print("std.AutoHashMap: Hash map with automatic key type\n", .{});
    try stdout.print("std.BufMap: String map that manages key memory\n", .{});
    try stdout.print("std.BufSet: String set that manages memory\n", .{});
    try stdout.print("std.DoublyLinkedList: Doubly linked list implementation\n", .{});
    try stdout.print("std.PriorityQueue: Priority queue data structure\n\n", .{});
    
    // 3. IO
    try stdout.print("-- IO --\n", .{});
    try stdout.print("std.io: Input/output utilities\n", .{});
    try stdout.print("  * getStdIn(), getStdOut(), getStdErr()\n", .{});
    try stdout.print("  * Reader and Writer interfaces\n", .{});
    try stdout.print("  * BufferedReader, BufferedWriter\n", .{});
    try stdout.print("std.fs: File system operations\n", .{});
    try stdout.print("  * cwd(): Get current working directory\n", .{});
    try stdout.print("  * openFile(), createFile()\n", .{});
    try stdout.print("  * File.read(), File.write()\n\n", .{});

    // 4. String Formatting and Parsing
    try stdout.print("-- Formatting and Parsing --\n", .{});
    try stdout.print("std.fmt: String formatting\n", .{});
    try stdout.print("  * format(), formatBuf(), parseInt(), parseFloat()\n", .{});
    try stdout.print("std.ascii: ASCII character utilities\n", .{});
    try stdout.print("std.unicode: Unicode utilities\n", .{});
    try stdout.print("std.json: JSON parsing and serialization\n\n", .{});

    // 5. Debugging and Testing
    try stdout.print("-- Debugging and Testing --\n", .{});
    try stdout.print("std.debug: Debugging utilities\n", .{});
    try stdout.print("  * print(), assert(), panic()\n", .{});
    try stdout.print("std.testing: Testing utilities\n", .{});
    try stdout.print("  * expect(), expectEqual(), expectError()\n", .{});
    try stdout.print("  * allocator: Special testing allocator\n\n", .{});

    // 6. Concurrency and Time
    try stdout.print("-- Concurrency and Time --\n", .{});
    try stdout.print("std.Thread: Native OS thread support\n", .{});
    try stdout.print("std.time: Time-related functions\n", .{});
    try stdout.print("  * timestamp(): Get current Unix timestamp\n", .{});
    try stdout.print("  * sleep(): Pause execution\n\n", .{});
  
    // 7. Crypto and Math
    try stdout.print("-- Crypto and Math --\n", .{});
    try stdout.print("std.crypto: Cryptographic algorithms\n", .{});
    try stdout.print("std.math: Mathematical functions\n", .{});
    try stdout.print("std.rand: Random number generation\n", .{});
    try stdout.print("  * DefaultPrng: Default pseudo-random number generator\n", .{});
    try stdout.print("  * Random: Interface for random generators\n\n", .{});

    // 8. System and OS
    try stdout.print("-- System and OS --\n", .{});
    try stdout.print("std.os: OS-specific functionality\n", .{});
    try stdout.print("std.process: Process management\n", .{});
    try stdout.print("  * getEnvMap(): Get environment variables\n", .{});
    try stdout.print("  * getCwd(): Get current working directory\n", .{});
    try stdout.print("std.ChildProcess: Spawn child processes\n\n", .{});

    // Example: Demonstrate a random number generator
    try stdout.print("--- Quick Example: Random Numbers ---\n", .{});
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    
    const random_int = rand.intRangeAtMost(i32, 1, 100);
    try stdout.print("Random integer between 1 and 100: {d}\n", .{random_int});
    
    const random_float = rand.float(f32);
    try stdout.print("Random float between 0 and 1: {d:.6}\n\n", .{random_float});
    
    try stdout.print("=== End of Standard Library Overview ===\n", .{});
}
