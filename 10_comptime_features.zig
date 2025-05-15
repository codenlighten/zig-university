const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    
    try stdout.print("\n=== Zig Compile-Time Features Examples ===\n\n", .{});
    
    // Example 1: Compile-time constants and operations
    try stdout.print("-- Example 1: Compile-Time Constants --\n", .{});
    try comptimeConstantsExample(stdout);
    try stdout.print("\n", .{});
    
    // Example 2: Generic Data Structures with Comptime
    try stdout.print("-- Example 2: Generic Data Structures --\n", .{});
    try genericDataStructuresExample(stdout);
    try stdout.print("\n", .{});
    
    // Example 3: Compile-time function evaluation
    try stdout.print("-- Example 3: Compile-Time Function Evaluation --\n", .{});
    try comptimeFunctionExample(stdout);
    try stdout.print("\n", .{});
    
    // Example 4: Comptime Types and Function Specialization
    try stdout.print("-- Example 4: Comptime Types and Function Specialization --\n", .{});
    try comptimeTypeExample(stdout);
    try stdout.print("\n", .{});
    
    // Example 5: Compile-time Reflection
    try stdout.print("-- Example 5: Compile-time Reflection --\n", .{});
    try comptimeReflectionExample(stdout);
    try stdout.print("\n", .{});
    
    try stdout.print("=== End of Compile-Time Features Examples ===\n", .{});
}

// Example 1: Compile-time constants and operations
fn comptimeConstantsExample(writer: anytype) !void {
    // Compile-time constants
    const ct_array = [_]u8{ 1, 2, 3, 4, 5 };
    const ct_string = "Hello, comptime!";
    
    try writer.print("Compile-time array: {any}\n", .{ct_array});
    try writer.print("Compile-time array length: {d}\n", .{ct_array.len});
    try writer.print("Compile-time string length: {d}\n", .{ct_string.len});
    
    // Compile-time math calculations
    const pi = std.math.pi;
    const radius = 5.0;
    const area = comptime pi * radius * radius;
    
    try writer.print("Circle area (calculated at compile time): {d:.4}\n", .{area});
    
    // Compile-time branching
    const OS = @import("builtin").os.tag;
    const os_name = comptime switch (OS) {
        .linux => "Linux",
        .windows => "Windows",
        .macos => "macOS",
        else => "Other OS",
    };
    try writer.print("Compiled for: {s}\n", .{os_name});
    
    // Concatenation at compile time
    const combined = comptime blk: {
        var result: [ct_string.len + 2 + 1]u8 = undefined;
        for (ct_string, 0..) |c, i| {
            result[i] = c;
        }
        result[ct_string.len] = ' ';
        result[ct_string.len + 1] = '!';
        result[ct_string.len + 2] = 0; // null terminator
        break :blk result;
    };
    try writer.print("Compile-time string manipulation: {s}\n", .{combined[0 .. combined.len - 1]});
}

// Example 2: Generic Data Structures with Comptime
fn genericDataStructuresExample(writer: anytype) !void {
    // Define a generic stack data structure
    const Stack = struct {
        // Using comptime to create type-specific stack implementations
        fn Of(comptime T: type) type {
            return struct {
                items: []T,
                len: usize,
                allocator: std.mem.Allocator,
                
                const Self = @This();
                
                fn init(allocator: std.mem.Allocator, capacity: usize) !Self {
                    const items = try allocator.alloc(T, capacity);
                    return Self{
                        .items = items,
                        .len = 0,
                        .allocator = allocator,
                    };
                }
                
                fn deinit(self: *Self) void {
                    self.allocator.free(self.items);
                }
                
                fn push(self: *Self, value: T) !void {
                    if (self.len >= self.items.len) {
                        return error.StackFull;
                    }
                    self.items[self.len] = value;
                    self.len += 1;
                }
                
                fn pop(self: *Self) !T {
                    if (self.len == 0) {
                        return error.StackEmpty;
                    }
                    self.len -= 1;
                    return self.items[self.len];
                }
                
                fn peek(self: Self) !T {
                    if (self.len == 0) {
                        return error.StackEmpty;
                    }
                    return self.items[self.len - 1];
                }
            };
        }
    };
    
    // Create stacks of different types using our generic implementation
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    // Integer stack
    const IntStack = Stack.Of(i32);
    var int_stack = try IntStack.init(allocator, 10);
    defer int_stack.deinit();
    
    try int_stack.push(10);
    try int_stack.push(20);
    try int_stack.push(30);
    
    try writer.print("Integer Stack: Top = {d}\n", .{try int_stack.peek()});
    try writer.print("Popped from Integer Stack: {d}\n", .{try int_stack.pop()});
    try writer.print("New Top = {d}\n", .{try int_stack.peek()});
    
    // String stack
    const StringStack = Stack.Of([]const u8);
    var string_stack = try StringStack.init(allocator, 10);
    defer string_stack.deinit();
    
    try string_stack.push("Hello");
    try string_stack.push("World");
    try string_stack.push("Zig");
    
    try writer.print("\nString Stack: Top = {s}\n", .{try string_stack.peek()});
    try writer.print("Popped from String Stack: {s}\n", .{try string_stack.pop()});
    try writer.print("New Top = {s}\n", .{try string_stack.peek()});
    
    // Show size information
    try writer.print("\nStack implementations:\n", .{});
    try writer.print("- Size of IntStack: {} bytes\n", .{@sizeOf(IntStack)});
    try writer.print("- Size of StringStack: {} bytes\n", .{@sizeOf(StringStack)});
}

// Example 3: Compile-time function evaluation
fn comptimeFunctionExample(writer: anytype) !void {
    // Fibonacci calculated at compile time
    const fib = struct {
        fn calc(n: u32) u32 {
            if (n <= 1) return n;
            return calc(n - 1) + calc(n - 2);
        }
    }.calc;
    
    // Calculate first 10 Fibonacci numbers at compile time
    const fibs = comptime blk: {
        var result: [10]u32 = undefined;
        for (&result, 0..) |*f, i| {
            f.* = fib(i);
        }
        break :blk result;
    };
    
    // Print the compile-time generated sequence
    try writer.print("First 10 Fibonacci numbers (calculated at compile time):\n", .{});
    for (fibs, 0..) |f, i| {
        try writer.print("  fib({d}) = {d}\n", .{ i, f });
    }
    
    // Another compile-time computation - calculating powers
    const pow = struct {
        fn calculate(base: u32, exponent: u32) u32 {
            if (exponent == 0) return 1;
            return base * calculate(base, exponent - 1);
        }
    }.calculate;
    
    // Create a lookup table of powers at compile time
    const powers_of_2 = comptime blk: {
        var result: [8]u32 = undefined;
        for (&result, 0..) |*p, i| {
            p.* = pow(2, i);
        }
        break :blk result;
    };
    
    try writer.print("\nPowers of 2 (calculated at compile time):\n", .{});
    for (powers_of_2, 0..) |p, i| {
        try writer.print("  2^{d} = {d}\n", .{ i, p });
    }
}

// Example 4: Comptime types and function specialization
fn comptimeTypeExample(writer: anytype) !void {
    // Function that behaves differently based on compile-time type parameter
    const specialized = struct {
        fn print(comptime T: type, value: T, output: anytype) !void {
            // Switch on the type to provide specialized behavior
            switch (@typeInfo(T)) {
                .int => {
                    try output.print("Integer value: {d} (in hex: 0x{x})\n", .{ value, value });
                },
                .float => {
                    try output.print("Float value: {d:.4} (scientific notation: {d:.4})\n", .{ value, value });
                },
                .pointer => |ptr_info| {
                    if (ptr_info.child == u8) {
                        // Treat []u8 or [*]u8 as strings
                        try output.print("String value: \"{s}\" (length: {d})\n", .{ value, value.len });
                    } else {
                        try output.print("Pointer to type {}\n", .{@typeName(ptr_info.child)});
                    }
                },
                else => {
                    try output.print("Value of type {}\n", .{@typeName(T)});
                },
            }
        }
    }.print;
    
    try writer.print("Type-specialized function examples:\n", .{});
    
    try specialized(i32, 42, writer);
    try specialized(f64, 3.14159, writer);
    try specialized([]const u8, "Hello, Zig!", writer);
    
    // Compile-time type creation 
    try writer.print("\nCompile-time type creation examples:\n", .{});
    
    // Create a specialized vector type at compile time
    const Vector = struct {
        fn Of(comptime T: type, comptime size: usize) type {
            return struct {
                data: [size]T,
                
                const Self = @This();
                
                fn init(values: [size]T) Self {
                    return Self{ .data = values };
                }
                
                fn get(self: Self, index: usize) T {
                    if (index >= size) @panic("Index out of bounds");
                    return self.data[index];
                }
                
                fn add(self: Self, other: Self) Self {
                    var result: [size]T = undefined;
                    for (&result, 0..) |*r, i| {
                        r.* = self.data[i] + other.data[i];
                    }
                    return Self{ .data = result };
                }
                
                fn dot(self: Self, other: Self) T {
                    var result: T = 0;
                    for (0..size) |i| {
                        result += self.data[i] * other.data[i];
                    }
                    return result;
                }
            };
        }
    };
    
    // Create different types of vectors
    const Vec3i = Vector.Of(i32, 3);
    const Vec3f = Vector.Of(f32, 3); 
    
    const v1 = Vec3i.init(.{1, 2, 3});
    const v2 = Vec3i.init(.{4, 5, 6});
    const v3 = v1.add(v2);
    
    try writer.print("Vector operations with integers:\n", .{});
    try writer.print("  v1 + v2 = ({d}, {d}, {d})\n", .{ v3.get(0), v3.get(1), v3.get(2) });
    try writer.print("  v1 · v2 = {d}\n", .{v1.dot(v2)});
    
    const vf1 = Vec3f.init(.{1.5, 2.5, 3.5});
    const vf2 = Vec3f.init(.{0.5, 1.0, 1.5});
    const vf3 = vf1.add(vf2);
    
    try writer.print("\nVector operations with floats:\n", .{});
    try writer.print("  vf1 + vf2 = ({d:.1}, {d:.1}, {d:.1})\n", .{ vf3.get(0), vf3.get(1), vf3.get(2) });
    try writer.print("  vf1 · vf2 = {d:.2}\n", .{vf1.dot(vf2)});
    
    // Show the sizes of these types
    try writer.print("\nType sizes:\n", .{});
    try writer.print("  Vec3i: {d} bytes\n", .{@sizeOf(Vec3i)});
    try writer.print("  Vec3f: {d} bytes\n", .{@sizeOf(Vec3f)});
}

// Example 5: Compile-time reflection
fn comptimeReflectionExample(writer: anytype) !void {
    try writer.print("Compile-time reflection examples:\n", .{});
    
    // Type information
    try writer.print("\nType information:\n", .{});
    try writer.print("  Size of u8: {d} bytes\n", .{@sizeOf(u8)});
    try writer.print("  Size of i32: {d} bytes\n", .{@sizeOf(i32)});
    try writer.print("  Size of f64: {d} bytes\n", .{@sizeOf(f64)});
    try writer.print("  Alignment of u8: {d} bytes\n", .{@alignOf(u8)});
    try writer.print("  Alignment of i32: {d} bytes\n", .{@alignOf(i32)});
    try writer.print("  Alignment of f64: {d} bytes\n", .{@alignOf(f64)});
    
    // Field introspection
    const Point = struct {
        x: i32,
        y: i32,
        
        fn distance(self: @This()) f32 {
            const sum = self.x * self.x + self.y * self.y;
            return @sqrt(@as(f32, @floatFromInt(sum)));
        }
    };
    
    try writer.print("\nStruct field reflection:\n", .{});
    try writer.print("  Size of Point: {d} bytes\n", .{@sizeOf(Point)});
    
    // Print field names and types using inline for
    try writer.print("  Fields of Point struct:\n", .{});
    inline for (std.meta.fields(Point)) |field| {
        try writer.print("    {s}: {s}\n", .{ field.name, @typeName(field.type) });
    }
    
    // Enum reflection
    const Color = enum {
        Red,
        Green,
        Blue,
        
        fn isRed(self: @This()) bool {
            return self == .Red;
        }
    };
    
    try writer.print("\nEnum reflection:\n", .{});
    try writer.print("  Size of Color enum: {d} bytes\n", .{@sizeOf(Color)});
    
    // Print all enum values
    try writer.print("  Enum values:\n", .{});
    inline for (std.meta.fields(Color)) |field| {
        try writer.print("    {s}\n", .{field.name});
    }
    
    // Runtime behavior can adapt to compile-time information
    try writer.print("\nAdapting to target systems:\n", .{});
    
    const os = @import("builtin").os.tag;
    const arch = @import("builtin").cpu.arch;
    
    try writer.print("  Compiled for OS: {s}\n", .{@tagName(os)});
    try writer.print("  CPU architecture: {s}\n", .{@tagName(arch)});
    
    const is_64bit = @sizeOf(usize) == 8;
    try writer.print("  Running in {s} mode\n", .{if (is_64bit) "64-bit" else "32-bit"});
}
