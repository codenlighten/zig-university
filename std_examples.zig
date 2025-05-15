const std = @import("std");

pub fn main() !void {
    // Get a handle to stdout for printing
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig Standard Library Examples ===\n\n", .{});

    // Create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Example 1: Working with ArrayList
    try stdout.print("-- ArrayList Example --\n", .{});
    var list = std.ArrayList(u32).init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(20);
    try list.append(30);
    try list.appendSlice(&[_]u32{ 40, 50, 60 });

    try stdout.print("List contents: ", .{});
    for (list.items, 0..) |item, i| {
        if (i > 0) try stdout.print(", ", .{});
        try stdout.print("{d}", .{item});
    }
    try stdout.print("\nList length: {d}\n\n", .{list.items.len});

    // Example 2: Working with HashMap
    try stdout.print("-- HashMap Example --\n", .{});
    var map = std.StringHashMap(i32).init(allocator);
    defer map.deinit();

    try map.put("one", 1);
    try map.put("two", 2);
    try map.put("three", 3);
    try map.put("four", 4);

    try stdout.print("Map contents:\n", .{});
    var it = map.iterator();
    while (it.next()) |entry| {
        try stdout.print("  {s}: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
    try stdout.print("\n", .{});

    // Example 3: String manipulation
    try stdout.print("-- String Manipulation --\n", .{});
    const original = "  Hello, Zig!  ";
    
    // Trim spaces
    const trimmed = std.mem.trim(u8, original, " ");
    try stdout.print("Original: '{s}'\n", .{original});
    try stdout.print("Trimmed: '{s}'\n", .{trimmed});
    
    // Split string
    try stdout.print("Split by comma: ", .{});
    var splits = std.mem.split(u8, trimmed, ",");
    var first = true;
    while (splits.next()) |token| {
        if (!first) try stdout.print(" | ", .{});
        try stdout.print("'{s}'", .{std.mem.trim(u8, token, " ")});
        first = false;
    }
    try stdout.print("\n\n", .{});

    // Example 4: File I/O
    try stdout.print("-- File I/O Example --\n", .{});
    const filename = "test_file.txt";
    
    // Write to file
    {
        const file = try std.fs.cwd().createFile(
            filename,
            .{ .read = true, .truncate = true },
        );
        defer file.close();
        
        try file.writeAll("This is a test file.\nCreated using Zig standard library.\n");
        try stdout.print("Wrote data to {s}\n", .{filename});
    }
    
    // Read from file
    {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();
        
        const stat = try file.stat();
        const file_size = stat.size;
        
        try stdout.print("File size: {d} bytes\n", .{file_size});
        
        const contents = try file.readToEndAlloc(allocator, file_size);
        defer allocator.free(contents);
        
        try stdout.print("File contents:\n{s}\n", .{contents});
    }

    // Example 5: Random number generation
    try stdout.print("\n-- Random Number Generation --\n", .{});
    var prng = std.rand.DefaultPrng.init(blk: {
        var seed: u64 = undefined;
        try std.os.getrandom(std.mem.asBytes(&seed));
        break :blk seed;
    });
    const rand = prng.random();
    
    // Generate 5 random integers between 1 and 100
    try stdout.print("5 random integers (1-100): ", .{});
    for (0..5) |i| {
        if (i > 0) try stdout.print(", ", .{});
        try stdout.print("{d}", .{rand.intRangeAtMost(u8, 1, 100)});
    }
    try stdout.print("\n\n", .{});

    // Example 6: Time functions
    try stdout.print("-- Time Functions --\n", .{});
    const current_time = std.time.timestamp();
    try stdout.print("Current Unix timestamp: {d}\n", .{current_time});
    
    // Sleep for a moment
    try stdout.print("Sleeping for 1 second...\n", .{});
    std.time.sleep(std.time.ns_per_s * 1);
    try stdout.print("Awake!\n\n", .{});

    try stdout.print("=== End of Examples ===\n", .{});
}
