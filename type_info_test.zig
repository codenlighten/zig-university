const std = @import("std");

pub fn main() !void {
    comptime {
        const T = u8;
        const info = @typeInfo(T);
        @compileLog("Type info tag for u8: ", @tagName(info));
    }
}
