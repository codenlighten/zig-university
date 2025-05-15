const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig Data Structures Examples ===\n\n", .{});

    // Create a general purpose allocator for our examples
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 1. ArrayList - Dynamic resizeable array
    try stdout.print("-- ArrayList --\n", .{});
    var list = std.ArrayList(i32).init(allocator);
    defer list.deinit();

    // Adding elements
    try list.append(10);
    try list.append(20);
    try list.append(30);
    try list.appendSlice(&[_]i32{ 40, 50, 60 });

    // Reading elements
    try stdout.print("First element: {d}\n", .{list.items[0]});
    try stdout.print("All elements: ", .{});
    for (list.items, 0..) |item, i| {
        if (i > 0) try stdout.print(", ", .{});
        try stdout.print("{d}", .{item});
    }
    try stdout.print("\n", .{});

    // Modifying elements
    list.items[1] = 25;
    try stdout.print("After updating index 1: ", .{});
    for (list.items, 0..) |item, i| {
        if (i > 0) try stdout.print(", ", .{});
        try stdout.print("{d}", .{item});
    }
    try stdout.print("\n", .{});

    // Removing elements
    _ = list.orderedRemove(2); // Remove element at index 2
    try stdout.print("After removing index 2: ", .{});
    for (list.items, 0..) |item, i| {
        if (i > 0) try stdout.print(", ", .{});
        try stdout.print("{d}", .{item});
    }
    try stdout.print("\n\n", .{});

    // 2. StringHashMap - A HashMap with string keys
    try stdout.print("-- StringHashMap --\n", .{});
    var string_map = std.StringHashMap(i32).init(allocator);
    defer string_map.deinit();

    // Adding entries
    try string_map.put("one", 1);
    try string_map.put("two", 2);
    try string_map.put("three", 3);

    // Reading entries
    try stdout.print("Map contents:\n", .{});
    var map_it = string_map.iterator();
    while (map_it.next()) |entry| {
        try stdout.print("  {s}: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }

    // Checking for existence
    if (string_map.get("two")) |value| {
        try stdout.print("Found 'two' with value: {d}\n", .{value});
    }

    if (string_map.get("four")) |value| {
        try stdout.print("Found 'four' with value: {d}\n", .{value});
    } else {
        try stdout.print("'four' not found in the map\n", .{});
    }

    // Removing entries
    _ = string_map.remove("two");
    try stdout.print("After removing 'two':\n", .{});
    var map_it2 = string_map.iterator();
    while (map_it2.next()) |entry| {
        try stdout.print("  {s}: {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
    try stdout.print("\n", .{});

    // 3. AutoHashMap - HashMap with any key type
    try stdout.print("-- AutoHashMap --\n", .{});
    var auto_map = std.AutoHashMap(u32, []const u8).init(allocator);
    defer auto_map.deinit();

    // Adding entries
    try auto_map.put(1, "one");
    try auto_map.put(2, "two");
    try auto_map.put(3, "three");

    // Reading entries
    try stdout.print("Auto map contents:\n", .{});
    var auto_it = auto_map.iterator();
    while (auto_it.next()) |entry| {
        try stdout.print("  {d}: {s}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    }
    try stdout.print("\n", .{});

    // 4. BufSet - A set of strings that owns the memory
    try stdout.print("-- BufSet --\n", .{});
    var string_set = std.BufSet.init(allocator);
    defer string_set.deinit();

    // Adding values
    try string_set.insert("apple");
    try string_set.insert("banana");
    try string_set.insert("cherry");
    try string_set.insert("apple"); // Duplicate, won't be added twice

    // Check for existence
    try stdout.print("Contains 'banana': {}\n", .{string_set.contains("banana")});
    try stdout.print("Contains 'grape': {}\n", .{string_set.contains("grape")});

    // Iterate over values
    try stdout.print("Set contents: ", .{});
    var set_it = string_set.iterator();
    var first = true;
    while (set_it.next()) |value| {
        if (!first) try stdout.print(", ", .{});
        try stdout.print("{s}", .{value});
        first = false;
    }
    try stdout.print("\n\n", .{});

    // 5. SinglyLinkedList
    try stdout.print("-- SinglyLinkedList --\n", .{});
    
    // Define a Node type for our linked list
    const Node = struct {
        data: i32,
        next: ?*@This(),

        fn init(alloc: std.mem.Allocator, data: i32) !*@This() {
            const node = try alloc.create(@This());
            node.* = .{
                .data = data,
                .next = null,
            };
            return node;
        }
    };

    // Create some nodes
    var head = try Node.init(allocator, 1);
    defer allocator.destroy(head);
    
    var node2 = try Node.init(allocator, 2);
    defer allocator.destroy(node2);
    head.next = node2;
    
    const node3 = try Node.init(allocator, 3);
    defer allocator.destroy(node3);
    node2.next = node3;

    // Traverse the linked list
    try stdout.print("Linked list contents: ", .{});
    var current: ?*Node = head;
    var is_first = true;
    while (current) |node| {
        if (!is_first) try stdout.print(" -> ", .{});
        try stdout.print("{d}", .{node.data});
        is_first = false;
        current = node.next;
    }
    try stdout.print("\n\n", .{});

    try stdout.print("=== End of Data Structures Examples ===\n", .{});
}
