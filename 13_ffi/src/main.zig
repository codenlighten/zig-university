const std = @import("std");

// Import C library definitions
const c = @cImport({
    @cInclude("c_library.h");
});

pub fn main() !void {
    // Setup
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const stdout = std.io.getStdOut().writer();
    
    try stdout.print("\n=== Zig FFI (Foreign Function Interface) Example ===\n\n", .{});

    // Example 1: Calling simple C functions
    try stdout.print("-- Example 1: Basic C Function Calls --\n", .{});
    try basicFunctionCalls(stdout);
    try stdout.print("\n", .{});
    
    // Example 2: Working with C strings
    try stdout.print("-- Example 2: Working with C Strings --\n", .{});
    try cStringOperations(stdout, allocator);
    try stdout.print("\n", .{});
    
    // Example 3: Using C structs from Zig
    try stdout.print("-- Example 3: Using C Structs --\n", .{});
    try cStructOperations(stdout);
    try stdout.print("\n", .{});
    
    // Example 4: Memory management across FFI boundary
    try stdout.print("-- Example 4: Memory Management with FFI --\n", .{});
    try memoryManagement(stdout);
    try stdout.print("\n", .{});
    
    try stdout.print("=== End of FFI Example ===\n", .{});
}

// Example 1: Calling basic C functions
fn basicFunctionCalls(writer: anytype) !void {
    // Call the C function directly
    const a: i32 = 42;
    const b: i32 = 27;
    const result = c.add_numbers(a, b);
    
    try writer.print("From C: {d} + {d} = {d}\n", .{ a, b, result });
    
    // Compare with Zig implementation
    const zig_result = a + b;
    try writer.print("From Zig: {d} + {d} = {d}\n", .{ a, b, zig_result });
    
    // C library function call
    try writer.print("Both results equal? {}\n", .{result == zig_result});
}

// Example 2: Working with C strings
fn cStringOperations(writer: anytype, allocator: std.mem.Allocator) !void {
    // Create Zig strings
    const str1 = "Hello, ";
    const str2 = "C from Zig!";
    
    // Convert to C-compatible strings (null-terminated)
    var c_str1 = try allocator.alloc(u8, str1.len + 1);
    defer allocator.free(c_str1);
    @memcpy(c_str1[0..str1.len], str1);
    c_str1[str1.len] = 0; // null terminator
    
    var c_str2 = try allocator.alloc(u8, str2.len + 1);
    defer allocator.free(c_str2);
    @memcpy(c_str2[0..str2.len], str2);
    c_str2[str2.len] = 0; // null terminator
    
    // Call C function to concatenate strings
    const c_result = c.concatenate_strings(c_str1.ptr, c_str2.ptr);
    defer std.c.free(c_result); // Free memory allocated by C
    
    // Convert C string back to Zig string for printing
    const result_len = std.mem.len(c_result);
    const zig_result = c_result[0..result_len];
    
    try writer.print("String 1: \"{s}\"\n", .{str1});
    try writer.print("String 2: \"{s}\"\n", .{str2});
    try writer.print("Concatenated by C: \"{s}\"\n", .{zig_result});
    
    // Compare with Zig implementation
    const zig_concat = try std.fmt.allocPrint(allocator, "{s}{s}", .{ str1, str2 });
    defer allocator.free(zig_concat);
    
    try writer.print("Concatenated by Zig: \"{s}\"\n", .{zig_concat});
    try writer.print("Strings equal? {}\n", .{std.mem.eql(u8, zig_result, zig_concat)});
}

// Example 3: Using C structs from Zig
fn cStructOperations(writer: anytype) !void {
    // Create a C struct instance directly in Zig
    var item = c.Item{
        .id = 1,
        .name = undefined,
        .value = 99.99,
    };
    
    // Set the name safely
    const name = "Zig-Created Item";
    @memcpy(item.name[0..name.len], name);
    item.name[name.len] = 0; // Null terminator
    
    // Print info about the struct using Zig
    try writer.print("Item created in Zig:\n", .{});
    try writer.print("  ID: {d}\n", .{item.id});
    try writer.print("  Name: {s}\n", .{name});
    try writer.print("  Value: {d:.2}\n", .{item.value});
    
    // Let the C function print the item
    try writer.print("\nSame item printed by C function:\n", .{});
    c.print_item(&item);
    
    // Initialize a new item using C function
    var another_item: c.Item = undefined;
    const another_name = "C-Initialized Item";
    var c_name = try std.heap.c_allocator.alloc(u8, another_name.len + 1);
    defer std.heap.c_allocator.free(c_name);
    @memcpy(c_name[0..another_name.len], another_name);
    c_name[another_name.len] = 0; // null terminator
    
    c.initialize_item(&another_item, 42, c_name.ptr, 123.456);
    
    try writer.print("\nItem initialized by C function:\n", .{});
    c.print_item(&another_item);
}

// Example 4: Memory management with FFI
fn memoryManagement(writer: anytype) !void {
    // Create a collection using C function (memory allocated by C)
    const title = "My Collection";
    var c_title = try std.heap.c_allocator.alloc(u8, title.len + 1);
    defer std.heap.c_allocator.free(c_title);
    @memcpy(c_title[0..title.len], title);
    c_title[title.len] = 0; // null terminator
    
    const collection = c.create_collection(c_title.ptr, 3);
    defer c.free_collection(collection); // Don't forget to free C-allocated memory!
    
    if (collection == null) {
        try writer.print("Error: Failed to create collection\n", .{});
        return;
    }
    
    // Access collection data from Zig
    // We need to dereference the C pointer to access struct fields
    const col = collection.*;
    
    // Need to convert C string to Zig string for printing
    const title_str = std.mem.sliceTo(col.title, 0);
    
    try writer.print("Collection Title: {s}\n", .{title_str});
    try writer.print("Number of Items: {d}\n", .{col.item_count});
    try writer.print("\nItems in collection:\n", .{});
    
    var i: usize = 0;
    while (i < col.item_count) : (i += 1) {
        // Items is an array of structs
        const item_ptr = &col.items[i];
        
        // Convert C string to Zig string - find the length by looking for null terminator
        const name_str = std.mem.sliceTo(&item_ptr.name, 0);
        
        try writer.print("  Item {d}: id={d}, name=\"{s}\", value={d:.2}\n", 
            .{ i + 1, item_ptr.id, name_str, item_ptr.value });
    }
    
    // Modify an item in the collection
    if (col.item_count > 0) {
        col.items[0].id = 999;
        
        const new_name = "Modified by Zig";
        @memcpy(col.items[0].name[0..new_name.len], new_name);
        col.items[0].name[new_name.len] = 0; // Null terminator
        
        col.items[0].value = 777.777;
        
        try writer.print("\nAfter modification from Zig:\n", .{});
        c.print_item(&col.items[0]);
    }
    
    // Memory management lessons
    try writer.print("\nMemory Management Lessons:\n", .{});
    try writer.print("1. Memory allocated in C must be freed in C\n", .{});
    try writer.print("2. Be careful with pointers across the FFI boundary\n", .{});
    try writer.print("3. Structs have the same memory layout in Zig and C\n", .{});
    try writer.print("4. Use defer for cleanup to prevent memory leaks\n", .{});
}
