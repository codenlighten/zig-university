const std = @import("std");

// Define a custom error set
const MathError = error{
    DivisionByZero,
    Overflow,
    Underflow,
};

// Define another error set
const FileError = error{
    NotFound,
    AccessDenied,
    OutOfSpace,
};

// Combined error set using merging
const AppError = MathError || FileError;

// Function that returns an error union type
fn divideOrError(a: i32, b: i32) MathError!i32 {
    if (b == 0) {
        return MathError.DivisionByZero;
    }
    
    if (a == std.math.minInt(i32) and b == -1) {
        return MathError.Overflow;
    }
    
    return @divTrunc(a, b);
}

// Function demonstrating the try operator
fn divideAndLog(a: i32, b: i32) MathError!i32 {
    // The try operator unwraps the value or returns the error
    const result = try divideOrError(a, b);
    return result;
}

// Function demonstrating the catch operator
fn divideWithFallback(a: i32, b: i32, fallback: i32) i32 {
    // The catch operator provides a fallback value
    return divideOrError(a, b) catch |err| {
        std.debug.print("Error occurred: {s}\n", .{@errorName(err)});
        return fallback;
    };
}

// Function that demonstrates errdefer
fn processFile(path: []const u8) (FileError || MathError)!void {
    // errdefer will only run if this function returns with an error
    errdefer {
        std.debug.print("Failed to process file: {s}\n", .{path});
    }
    
    // Simulate file operations with possible errors
    if (std.mem.eql(u8, path, "nonexistent.txt")) {
        return FileError.NotFound;
    }
    
    if (std.mem.eql(u8, path, "noaccess.txt")) {
        return FileError.AccessDenied;
    }
    
    // If we got here, the file operation was successful
    std.debug.print("Successfully processed file: {s}\n", .{path});
}

// Function demonstrating the switch on errors pattern
fn describeError(err: AppError) []const u8 {
    return switch (err) {
        MathError.DivisionByZero => "Cannot divide by zero",
        MathError.Overflow => "Result too large",
        MathError.Underflow => "Result too small",
        FileError.NotFound => "File not found",
        FileError.AccessDenied => "Access denied",
        FileError.OutOfSpace => "Out of disk space",
    };
}

// Optional-based error handling
fn findValue(array: []const i32, value: i32) ?usize {
    for (array, 0..) |item, i| {
        if (item == value) {
            return i;
        }
    }
    return null;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig Error Handling Examples ===\n\n", .{});

    // Create allocator for examples
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // 1. Basic error union handling
    try stdout.print("-- Basic Error Handling --\n", .{});
    
    // Successful calculation
    const success_result = divideOrError(10, 2) catch |err| {
        try stdout.print("Unexpected error: {s}\n", .{@errorName(err)});
        return;
    };
    try stdout.print("10 / 2 = {d}\n", .{success_result});
    
    // Error case
    const error_result = divideOrError(5, 0) catch |err| {
        try stdout.print("5 / 0 error: {s}\n", .{@errorName(err)});
        return;
    };
    // This line will not be reached due to the error
    try stdout.print("Result: {d}\n", .{error_result});
    
    try stdout.print("\n", .{});

    // 2. Using try operator
    try stdout.print("-- Using the try Operator --\n", .{});
    
    // This will succeed
    const try_result = try divideAndLog(20, 4);
    try stdout.print("20 / 4 = {d}\n", .{try_result});
    
    // This would cause the current function to return with the error
    // If uncommented, the program would end here
    // _ = try divideAndLog(7, 0);
    
    try stdout.print("\n", .{});

    // 3. Using catch operator
    try stdout.print("-- Using the catch Operator --\n", .{});
    
    // Successful case
    const catch_success = divideWithFallback(100, 5, 0);
    try stdout.print("100 / 5 = {d}\n", .{catch_success});
    
    // Error case with fallback
    const catch_error = divideWithFallback(100, 0, 42);
    try stdout.print("100 / 0 fallback = {d}\n", .{catch_error});
    
    try stdout.print("\n", .{});

    // 4. Using errdefer
    try stdout.print("-- Using errdefer --\n", .{});
    
    // Successful case
    processFile("valid.txt") catch |err| {
        try stdout.print("Process file error: {s}\n", .{@errorName(err)});
    };
    
    // Error case
    processFile("nonexistent.txt") catch |err| {
        try stdout.print("Process file error: {s}\n", .{@errorName(err)});
    };
    
    try stdout.print("\n", .{});

    // 5. Switch on errors
    try stdout.print("-- Switch on Errors --\n", .{});
    
    const errors = [_]AppError{
        MathError.DivisionByZero,
        FileError.NotFound,
        MathError.Overflow,
        FileError.AccessDenied,
    };
    
    for (errors) |err| {
        const description = describeError(err);
        try stdout.print("{s}: {s}\n", .{ @errorName(err), description });
    }
    
    try stdout.print("\n", .{});

    // 6. Optional error handling
    try stdout.print("-- Optional Error Handling --\n", .{});
    
    const numbers = [_]i32{ 10, 20, 30, 40, 50 };
    
    // Find a value that exists
    if (findValue(&numbers, 30)) |index| {
        try stdout.print("Found 30 at index {d}\n", .{index});
    } else {
        try stdout.print("Value 30 not found\n", .{});
    }
    
    // Find a value that doesn't exist
    if (findValue(&numbers, 60)) |index| {
        try stdout.print("Found 60 at index {d}\n", .{index});
    } else {
        try stdout.print("Value 60 not found\n", .{});
    }
    
    // Using the orelse operator
    const index = findValue(&numbers, 20) orelse {
        try stdout.print("Value 20 not found, using fallback\n", .{});
        return;
    };
    try stdout.print("Found 20 at index {d}\n", .{index});

    try stdout.print("\n=== End of Error Handling Examples ===\n", .{});
}
