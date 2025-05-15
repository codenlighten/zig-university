const std = @import("std");

pub fn main() !void {
    // Get a handle to stdout
    const stdout = std.io.getStdOut().writer();

    // Print a simple message
    try stdout.print("Exploring Zig Standard Library\n", .{});
    
    // Demonstrate some std functions
    const allocator = std.heap.page_allocator;
    
    // Create an ArrayList
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();
    
    // Add some data
    try list.appendSlice("Hello from Zig!");
    
    // Print the list contents
    try stdout.print("List contents: {s}\n", .{list.items});
    
    // Print memory usage
    try stdout.print("List capacity: {d}\n", .{list.capacity});
    
    // Print current time
    const timestamp = std.time.timestamp();
    try stdout.print("Current timestamp: {d}\n", .{timestamp});
}
