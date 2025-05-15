const std = @import("std");

/// Reverse a string
pub fn reverseString(allocator: std.mem.Allocator, text: []const u8) ![]u8 {
    const len = text.len;
    var result = try allocator.alloc(u8, len);
    
    for (text, 0..) |char, i| {
        result[len - i - 1] = char;
    }
    
    return result;
}

/// Count occurrences of a character in a string
pub fn countOccurrences(text: []const u8, char: u8) usize {
    var count: usize = 0;
    for (text) |c| {
        if (c == char) count += 1;
    }
    return count;
}

/// Generate random text of specified length
pub fn generateRandomText(allocator: std.mem.Allocator, length: usize) ![]u8 {
    var result = try allocator.alloc(u8, length);
    
    const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    const charset_len = charset.len;
    
    var i: usize = 0;
    while (i < length) : (i += 1) {
        const random_index = std.crypto.random.uintAtMost(u8, charset_len - 1);
        result[i] = charset[random_index];
    }
    
    return result;
}

/// StringStats structure
pub const StringStats = struct {
    allocator: std.mem.Allocator,
    length: usize,
    word_count: usize,
    uppercase_count: usize,
    lowercase_count: usize,
    digit_count: usize,
    space_count: usize,
    unique_chars: std.AutoHashMap(u8, void),
    
    /// Clean up resources
    pub fn deinit(self: *StringStats) void {
        self.unique_chars.deinit();
    }
};

/// Analyze a string and return statistics
pub fn getStringStats(allocator: std.mem.Allocator, text: []const u8) !StringStats {
    var stats = StringStats{
        .allocator = allocator,
        .length = text.len,
        .word_count = 0,
        .uppercase_count = 0,
        .lowercase_count = 0,
        .digit_count = 0,
        .space_count = 0,
        .unique_chars = std.AutoHashMap(u8, void).init(allocator),
    };
    
    var in_word = false;
    
    for (text) |char| {
        // Count unique characters
        try stats.unique_chars.put(char, {});
        
        // Count character types
        if (std.ascii.isUpper(char)) {
            stats.uppercase_count += 1;
        } else if (std.ascii.isLower(char)) {
            stats.lowercase_count += 1;
        } else if (std.ascii.isDigit(char)) {
            stats.digit_count += 1;
        } else if (std.ascii.isWhitespace(char)) {
            stats.space_count += 1;
            
            // Word counting
            if (in_word) {
                in_word = false;
            }
        } else {
            // Handle other characters
        }
        
        // Word counting (continued)
        if (!std.ascii.isWhitespace(char) and !in_word) {
            in_word = true;
            stats.word_count += 1;
        }
    }
    
    return stats;
}

// Tests
test "string reversal" {
    const allocator = std.testing.allocator;
    
    const text = "Hello, World!";
    const expected = "!dlroW ,olleH";
    
    const result = try reverseString(allocator, text);
    defer allocator.free(result);
    
    try std.testing.expectEqualStrings(expected, result);
}

test "character counting" {
    const text = "hello";
    const count = countOccurrences(text, 'l');
    
    try std.testing.expectEqual(@as(usize, 2), count);
}

test "string stats" {
    const allocator = std.testing.allocator;
    
    const text = "Hello, World 123!";
    var stats = try getStringStats(allocator, text);
    defer stats.deinit();
    
    try std.testing.expectEqual(@as(usize, 17), stats.length);
    try std.testing.expectEqual(@as(usize, 3), stats.word_count);
    try std.testing.expectEqual(@as(usize, 2), stats.uppercase_count);
    try std.testing.expectEqual(@as(usize, 8), stats.lowercase_count);
    try std.testing.expectEqual(@as(usize, 3), stats.digit_count);
    try std.testing.expectEqual(@as(usize, 2), stats.space_count);
    try std.testing.expectEqual(@as(usize, 13), stats.unique_chars.count());
}
