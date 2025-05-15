const std = @import("std");

// This declares the main build function that Zig will call
pub fn build(b: *std.Build) void {
    // Get standard target options
    const target = b.standardTargetOptions(.{});
    
    // Get standard optimization options
    const optimize = b.standardOptimizeOption(.{});
    
    // Define our executable
    const exe = b.addExecutable(.{
        .name = "build-example",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Make sure to link libc if needed for certain functions
    exe.linkLibC();
    
    // This creates an installation step - `zig build install` will install the executable
    b.installArtifact(exe);
    
    // Create a run step for convenient testing - `zig build run`
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    
    // Make the run step available by doing `zig build run`
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
    
    // Add a test step
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Create separate test steps for each module
    const math_tests = b.addTest(.{
        .root_source_file = b.path("src/math.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    const utils_tests = b.addTest(.{
        .root_source_file = b.path("src/utils.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // Create a command to run all tests
    const test_step = b.step("test", "Run all tests");
    
    // Add the run test commands to the test step
    const run_exe_tests = b.addRunArtifact(exe_unit_tests);
    test_step.dependOn(&run_exe_tests.step);
    
    const run_math_tests = b.addRunArtifact(math_tests);
    test_step.dependOn(&run_math_tests.step);
    
    const run_utils_tests = b.addRunArtifact(utils_tests);
    test_step.dependOn(&run_utils_tests.step);
    
    // Add a step to run documentation generation
    const docs = b.step("docs", "Generate documentation");
    
    // Documentation for main module
    const main_docs = b.addSystemCommand(&[_][]const u8{
        "zig", "test", "--test-filter", "/", "--test-cmd", "echo", "src/main.zig", 
    });
    docs.dependOn(&main_docs.step);
    
    // Documentation for math module
    const math_docs = b.addSystemCommand(&[_][]const u8{
        "zig", "test", "--test-filter", "/", "--test-cmd", "echo", "src/math.zig",
    });
    docs.dependOn(&math_docs.step);
    
    // Documentation for utils module
    const utils_docs = b.addSystemCommand(&[_][]const u8{
        "zig", "test", "--test-filter", "/", "--test-cmd", "echo", "src/utils.zig",
    });
    docs.dependOn(&utils_docs.step);
}
