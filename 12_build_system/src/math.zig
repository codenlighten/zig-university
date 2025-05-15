const std = @import("std");

/// Add two integers
pub fn add(a: i32, b: i32) i32 {
    return a + b;
}

/// Subtract b from a
pub fn subtract(a: i32, b: i32) i32 {
    return a - b;
}

/// Multiply two integers
pub fn multiply(a: i32, b: i32) i32 {
    return a * b;
}

/// Divide a by b
pub fn divide(a: i32, b: i32) i32 {
    if (b == 0) @panic("Division by zero");
    return @divTrunc(a, b);
}

/// Calculate a raised to the power of b
pub fn power(a: i32, b: i32) i32 {
    if (b < 0) @panic("Negative exponent not supported");
    if (b == 0) return 1;
    
    var result: i32 = 1;
    var i: i32 = 0;
    while (i < b) : (i += 1) {
        result *= a;
    }
    
    return result;
}

// Test functions
test "basic math operations" {
    const expect = std.testing.expect;
    
    try expect(add(3, 4) == 7);
    try expect(subtract(10, 5) == 5);
    try expect(multiply(3, 4) == 12);
    try expect(divide(10, 2) == 5);
    try expect(power(2, 3) == 8);
}

test "edge cases" {
    const expect = std.testing.expect;
    
    // Power of 0
    try expect(power(5, 0) == 1);
    try expect(power(0, 0) == 1);
    
    // Identity operations
    try expect(multiply(1, 42) == 42);
    try expect(divide(42, 1) == 42);
}
