const std = @import("std");

pub fn main() !void {
    comptime {
        // Test structure type tag
        const S = struct { x: i32 };
        const struct_info = @typeInfo(S);
        @compileLog("Struct tag: ", @tagName(struct_info));
        
        // Test enum type tag
        const E = enum { Red, Green, Blue };
        const enum_info = @typeInfo(E);
        @compileLog("Enum tag: ", @tagName(enum_info));
    }
}
