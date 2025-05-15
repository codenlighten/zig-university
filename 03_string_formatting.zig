const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig String Manipulation and Formatting ===\n\n", .{});

    // Create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 1. Basic string operations
    try stdout.print("-- Basic String Operations --\n", .{});
    const str1 = "Hello, Zig!";
    
    // String length
    try stdout.print("Length of '{s}': {d}\n", .{ str1, str1.len });
    
    // Indexing
    try stdout.print("First character: {c}\n", .{str1[0]});
    try stdout.print("Last character: {c}\n", .{str1[str1.len - 1]});

    // String slicing
    const hello = str1[0..5];
    try stdout.print("Slice [0..5]: '{s}'\n", .{hello});
    
    // String comparison
    const str2 = "Hello, World!";
    try stdout.print("str1 == str2: {}\n", .{std.mem.eql(u8, str1, str2)});
    try stdout.print("str1[0..5] == 'Hello': {}\n\n", .{std.mem.eql(u8, str1[0..5], "Hello")});

    // 2. String manipulation
    try stdout.print("-- String Manipulation --\n", .{});
    
    // Trim
    const padded_str = "  trim me  ";
    const trimmed = std.mem.trim(u8, padded_str, " ");
    try stdout.print("Original: '{s}', Trimmed: '{s}'\n", .{ padded_str, trimmed });
    
    const trimmed_left = std.mem.trimLeft(u8, padded_str, " ");
    try stdout.print("Left-trimmed: '{s}'\n", .{trimmed_left});
    
    const trimmed_right = std.mem.trimRight(u8, padded_str, " ");
    try stdout.print("Right-trimmed: '{s}'\n", .{trimmed_right});
    
    // Splitting
    const csv_line = "value1,value2,value3";
    try stdout.print("Splitting '{s}' by ',':\n", .{csv_line});
    
    var splits = std.mem.splitSequence(u8, csv_line, ",");
    while (splits.next()) |token| {
        try stdout.print("  '{s}'\n", .{token});
    }
    
    // Tokenizing
    const sentence = "This is a sample sentence with   multiple   spaces";
    try stdout.print("Tokenizing by whitespace: '{s}'\n", .{sentence});
    
    var tokens = std.mem.tokenizeScalar(u8, sentence, ' ');
    var token_count: usize = 0;
    while (tokens.next()) |token| {
        token_count += 1;
        try stdout.print("  Token {d}: '{s}'\n", .{ token_count, token });
    }
    try stdout.print("\n", .{});

    // 3. String concatenation
    try stdout.print("-- String Concatenation --\n", .{});
    
    // Array concatenation operator (for compile-time strings)
    const first = "Hello";
    const last = "World";
    const combined = first ++ ", " ++ last ++ "!";
    try stdout.print("Concatenated: '{s}'\n", .{combined});
    
    // Runtime concatenation with ArrayList
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();
    
    try buffer.appendSlice("Dynamic ");
    try buffer.appendSlice("string ");
    try buffer.appendSlice("concatenation");
    
    try stdout.print("ArrayList concatenation: '{s}'\n\n", .{buffer.items});

    // 4. String formatting
    try stdout.print("-- String Formatting --\n", .{});
    
    // Basic formatting
    const name = "Ziguana";
    const age = 42;
    const pi = 3.14159;
    
    try stdout.print("Name: {s}, Age: {d}, Pi: {d:.5}\n", .{ name, age, pi });
    
    // Format specifiers
    try stdout.print("Integer formatting:\n", .{});
    try stdout.print("  Decimal: {d}\n", .{255});
    try stdout.print("  Binary: {b}\n", .{255});
    try stdout.print("  Octal: {o}\n", .{255});
    try stdout.print("  Hexadecimal: 0x{x}\n", .{255});
    
    // Padding and alignment
    try stdout.print("Padding and alignment:\n", .{});
    try stdout.print("  Right-aligned, width 10: '{d:>10}'\n", .{42});
    try stdout.print("  Left-aligned, width 10: '{d:<10}'\n", .{42});
    try stdout.print("  Centered, width 10: '{d:^10}'\n", .{42});
    try stdout.print("  Zero-padded, width 5: '{d:0>5}'\n", .{42});
    
    // Dynamic formatting with buffer
    var fmt_buffer: [100]u8 = undefined;
    const formatted = try std.fmt.bufPrint(&fmt_buffer, "The answer is {d}!", .{42});
    try stdout.print("Formatted to buffer: '{s}'\n\n", .{formatted});

    // 5. Parsing strings to numbers
    try stdout.print("-- String Parsing --\n", .{});
    
    const int_str = "42";
    const parsed_int = try std.fmt.parseInt(i32, int_str, 10);
    try stdout.print("Parsed integer: {d}\n", .{parsed_int});
    
    const float_str = "3.14159";
    const parsed_float = try std.fmt.parseFloat(f64, float_str);
    try stdout.print("Parsed float: {d:.5}\n", .{parsed_float});
    
    // Handling potential parse errors
    const bad_int_str = "42abc";
    const parsed_bad_int = std.fmt.parseInt(i32, bad_int_str, 10) catch |err| {
        try stdout.print("Error parsing '{s}': {s}\n", .{ bad_int_str, @errorName(err) });
        return;
    };
    try stdout.print("Parsed bad integer: {d}\n", .{parsed_bad_int}); // Should not reach here

    try stdout.print("\n=== End of String Examples ===\n", .{});
}
