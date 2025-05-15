const std = @import("std");

pub fn build(b: *std.Build) void {
    // Standard target options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    // Create an executable
    const exe = b.addExecutable(.{
        .name = "ffi-example",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Add C source file to the build
    exe.addCSourceFile(.{
        .file = b.path("src/c_library.c"),
        .flags = &[_][]const u8{"-std=c99"},
    });
    
    // Link with libc
    exe.linkLibC();
    
    // Add C include path
    exe.addIncludePath(b.path("src"));
    
    // Install the executable
    b.installArtifact(exe);
    
    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    
    const run_step = b.step("run", "Run the FFI example");
    run_step.dependOn(&run_cmd.step);
}
