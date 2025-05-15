const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig Memory and Allocator Examples ===\n\n", .{});

    // 1. Fixed Buffer Allocator
    // Allocates from a fixed buffer, good for when memory usage must be bounded
    try stdout.print("-- Fixed Buffer Allocator --\n", .{});
    var buffer: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const fba_allocator = fba.allocator();

    const fba_memory = try fba_allocator.alloc(u8, 100);
    defer fba_allocator.free(fba_memory);
    @memset(fba_memory, 'A');
    
    try stdout.print("Fixed buffer allocated: {d} bytes\n", .{fba_memory.len});
    
    // In Zig 0.11.0, we can't directly access the internal buffer pointers
    // Let's allocate another chunk to see how much we can still allocate
    const remaining_test = fba_allocator.alloc(u8, 300) catch |err| {
        try stdout.print("Could not allocate 300 more bytes: {s}\n\n", .{@errorName(err)});
        return;
    };
    defer fba_allocator.free(remaining_test);
    try stdout.print("Could allocate {d} more bytes\n\n", .{remaining_test.len});

    // 2. Arena Allocator
    // Frees all memory at once, very efficient when you need to free everything at the end
    try stdout.print("-- Arena Allocator --\n", .{});
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    // Allocate multiple blocks of memory
    const block1 = try arena_allocator.alloc(u8, 50);
    const block2 = try arena_allocator.alloc(u32, 25);
    const block3 = try arena_allocator.alloc(u64, 10);
    
    @memset(block1, 'B');
    
    try stdout.print("Arena allocated blocks: {d}, {d}, and {d} bytes\n", .{
        block1.len,
        block2.len * @sizeOf(u32),
        block3.len * @sizeOf(u64),
    });
    try stdout.print("No need to free individual blocks with an arena!\n\n", .{});

    // 3. General Purpose Allocator
    // Production-grade allocator with leak detection in debug mode
    try stdout.print("-- General Purpose Allocator --\n", .{});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const check = gpa.deinit();
        if (check == .leak) {
            std.debug.print("Memory leaked from GPA\n", .{});
        }
    }
    const gpa_allocator = gpa.allocator();

    const gpa_memory = try gpa_allocator.alloc(u8, 200);
    @memset(gpa_memory, 'C');
    try stdout.print("GPA allocated: {d} bytes\n", .{gpa_memory.len});
    
    // Don't forget to free when using GPA
    gpa_allocator.free(gpa_memory);
    try stdout.print("GPA memory freed\n\n", .{});

    // 4. Page Allocator
    // Allocates directly from the OS in whole pages
    try stdout.print("-- Page Allocator --\n", .{});
    const page_allocator = std.heap.page_allocator;
    
    const page_memory = try page_allocator.alloc(u8, 4096);
    defer page_allocator.free(page_memory);
    @memset(page_memory, 'D');
    
    try stdout.print("Page allocator allocated: {d} bytes\n\n", .{page_memory.len});

    // 5. Memory operations
    try stdout.print("-- Memory Operations --\n", .{});
    
    // 5.1 Compare memory
    var buf1 = [_]u8{ 1, 2, 3, 4, 5 };
    var buf2 = [_]u8{ 1, 2, 3, 4, 5 };
    var buf3 = [_]u8{ 1, 2, 3, 9, 5 };
    
    const eq1 = std.mem.eql(u8, &buf1, &buf2);
    const eq2 = std.mem.eql(u8, &buf1, &buf3);
    
    try stdout.print("Memory equal (buf1, buf2): {}\n", .{eq1});
    try stdout.print("Memory equal (buf1, buf3): {}\n", .{eq2});
    
    // 5.2 Find differences
    const diff_index = std.mem.indexOfDiff(u8, &buf1, &buf3);
    try stdout.print("Difference at index: {?d}\n", .{diff_index});
    
    // 5.3 Memory copy (Zig 0.14.0 uses copyForwards)
    var dest = [_]u8{0} ** 5;
    @memcpy(&dest, &buf1);
    try stdout.print("After copy, dest contains: {any}\n", .{dest});
    
    // 5.4 Memory set (using @memset in Zig 0.14.0)
    var zeros = [_]u8{1} ** 10;
    @memset(&zeros, 0);
    try stdout.print("After memset, buffer contains: {any}\n\n", .{zeros});

    try stdout.print("=== End of Memory Examples ===\n", .{});
}
