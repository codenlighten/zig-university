const std = @import("std");

// Function we want to test
fn add(a: i32, b: i32) i32 {
    return a + b;
}

// Another function to test
fn fibonacci(n: u32) u32 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

// A struct with methods we want to test
const Calculator = struct {
    last_result: i32 = 0,
    
    // Reset the calculator
    pub fn reset(self: *Calculator) void {
        self.last_result = 0;
    }
    
    // Add a number to the current result
    pub fn add(self: *Calculator, value: i32) void {
        self.last_result += value;
    }
    
    // Subtract a number from the current result
    pub fn subtract(self: *Calculator, value: i32) void {
        self.last_result -= value;
    }
    
    // Multiply the current result by a number
    pub fn multiply(self: *Calculator, value: i32) void {
        self.last_result *= value;
    }
    
    // Get the current result
    pub fn getResult(self: Calculator) i32 {
        return self.last_result;
    }
};

// Basic test for add function
test "basic addition" {
    const result = add(3, 4);
    try std.testing.expectEqual(@as(i32, 7), result);
}

// Test multiple cases of the same function
test "multiple additions" {
    try std.testing.expectEqual(@as(i32, 5), add(2, 3));
    try std.testing.expectEqual(@as(i32, 0), add(0, 0));
    try std.testing.expectEqual(@as(i32, -8), add(-5, -3));
    try std.testing.expectEqual(@as(i32, 0), add(5, -5));
}

// Test fibonacci function
test "fibonacci sequence" {
    try std.testing.expectEqual(@as(u32, 0), fibonacci(0));
    try std.testing.expectEqual(@as(u32, 1), fibonacci(1));
    try std.testing.expectEqual(@as(u32, 1), fibonacci(2));
    try std.testing.expectEqual(@as(u32, 2), fibonacci(3));
    try std.testing.expectEqual(@as(u32, 3), fibonacci(4));
    try std.testing.expectEqual(@as(u32, 5), fibonacci(5));
    try std.testing.expectEqual(@as(u32, 8), fibonacci(6));
    try std.testing.expectEqual(@as(u32, 13), fibonacci(7));
}

// Test our Calculator struct
test "calculator operations" {
    var calc = Calculator{};
    
    // Initial state
    try std.testing.expectEqual(@as(i32, 0), calc.getResult());
    
    // Addition
    calc.add(5);
    try std.testing.expectEqual(@as(i32, 5), calc.getResult());
    
    // Subtraction
    calc.subtract(2);
    try std.testing.expectEqual(@as(i32, 3), calc.getResult());
    
    // Multiplication
    calc.multiply(4);
    try std.testing.expectEqual(@as(i32, 12), calc.getResult());
    
    // Reset
    calc.reset();
    try std.testing.expectEqual(@as(i32, 0), calc.getResult());
}

// Test that demonstrates allocation with testing allocator
test "array list with testing allocator" {
    // The testing allocator will detect memory leaks
    const allocator = std.testing.allocator;
    
    var list = std.ArrayList(i32).init(allocator);
    defer list.deinit(); // Don't forget to free the memory!
    
    try list.append(10);
    try list.append(20);
    try list.append(30);
    
    try std.testing.expectEqual(@as(usize, 3), list.items.len);
    try std.testing.expectEqual(@as(i32, 10), list.items[0]);
    try std.testing.expectEqual(@as(i32, 20), list.items[1]);
    try std.testing.expectEqual(@as(i32, 30), list.items[2]);
}

// Test that demonstrates expecting errors
test "expecting errors" {
    // A function that should return an error
    const result1 = std.fmt.parseInt(i32, "not a number", 10);
    try std.testing.expectError(error.InvalidCharacter, result1);
    
    // A function that should not return an error
    const result2 = std.fmt.parseInt(i32, "42", 10);
    try std.testing.expectEqual(@as(i32, 42), try result2);
}

// Test skipping example
test "skip this test" {
    // When you want to temporarily skip a test
    if (true) return error.SkipZigTest;
    
    // This code won't be executed
    unreachable;
}

// Test that demonstrates the use of test blocks in different scopes
const MathFunctions = struct {
    // Nested test inside a struct
    test "nested test in struct" {
        try std.testing.expect(true);
    }
    
    pub fn square(x: i32) i32 {
        return x * x;
    }
    
    pub fn cube(x: i32) i32 {
        return x * x * x;
    }
    
    // Another nested test
    test "square function" {
        try std.testing.expectEqual(@as(i32, 4), square(2));
        try std.testing.expectEqual(@as(i32, 9), square(3));
        try std.testing.expectEqual(@as(i32, 0), square(0));
    }
};

// Main function (not used during testing)
pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig Testing Example ===\n\n", .{});
    
    try stdout.print("This file is designed to be run with 'zig test' rather than 'zig run'.\n", .{});
    try stdout.print("Try running it with: zig test 06_testing.zig\n", .{});
    
    try stdout.print("\nAdd function demo: {d} + {d} = {d}\n", .{ 5, 7, add(5, 7) });
    
    try stdout.print("\nCalculator demo:\n", .{});
    var calc = Calculator{};
    calc.add(10);
    try stdout.print("Add 10: {d}\n", .{calc.getResult()});
    calc.multiply(2);
    try stdout.print("Multiply by 2: {d}\n", .{calc.getResult()});
    calc.subtract(5);
    try stdout.print("Subtract 5: {d}\n", .{calc.getResult()});
    
    try stdout.print("\nFibonacci sequence (first 8 numbers):\n", .{});
    for (0..8) |i| {
        const n = @as(u32, @intCast(i));
        try stdout.print("fibonacci({d}) = {d}\n", .{ n, fibonacci(n) });
    }
    
    try stdout.print("\n=== End of Testing Example ===\n", .{});
}
