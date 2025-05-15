const std = @import("std");
const math = @import("math.zig");
const utils = @import("utils.zig");

pub fn main() !void {
    // Setup
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const stdout = std.io.getStdOut().writer();
    
    try stdout.print("\n=== Zig Build System Example ===\n\n", .{});
    
    // Math module examples
    try stdout.print("-- Math Module --\n", .{});
    const a = 10;
    const b = 5;
    
    try stdout.print("Addition: {d} + {d} = {d}\n", .{ a, b, math.add(a, b) });
    try stdout.print("Subtraction: {d} - {d} = {d}\n", .{ a, b, math.subtract(a, b) });
    try stdout.print("Multiplication: {d} * {d} = {d}\n", .{ a, b, math.multiply(a, b) });
    try stdout.print("Division: {d} / {d} = {d}\n", .{ a, b, math.divide(a, b) });
    try stdout.print("Power: {d}^{d} = {d}\n", .{ a, b, math.power(a, b) });
    
    // Utils module examples
    try stdout.print("\n-- Utils Module --\n", .{});
    
    const text = "Hello, Zig Build System!";
    try stdout.print("Original text: \"{s}\"\n", .{text});
    
    // Reverse string
    const reversed = try utils.reverseString(allocator, text);
    defer allocator.free(reversed);
    try stdout.print("Reversed text: \"{s}\"\n", .{reversed});
    
    // Count occurrences
    const char_to_count = 'i';
    const count = utils.countOccurrences(text, char_to_count);
    try stdout.print("Count of '{c}' in the text: {d}\n", .{ char_to_count, count });
    
    // Generate random text
    const random_length = 16;
    const random_text = try utils.generateRandomText(allocator, random_length);
    defer allocator.free(random_text);
    try stdout.print("Random text ({d} chars): \"{s}\"\n", .{ random_length, random_text });
    
    // String stats
    var stats = try utils.getStringStats(allocator, text);
    defer stats.deinit();
    
    try stdout.print("\nText Statistics:\n", .{});
    try stdout.print("  Length: {d}\n", .{stats.length});
    try stdout.print("  Words: {d}\n", .{stats.word_count});
    try stdout.print("  Uppercase: {d}\n", .{stats.uppercase_count});
    try stdout.print("  Lowercase: {d}\n", .{stats.lowercase_count});
    try stdout.print("  Digits: {d}\n", .{stats.digit_count});
    try stdout.print("  Spaces: {d}\n", .{stats.space_count});
    try stdout.print("  Unique characters: {d}\n", .{stats.unique_chars.count()});
    
    try stdout.print("\n=== End of Build System Example ===\n", .{});
}
