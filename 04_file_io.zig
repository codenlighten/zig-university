const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig File I/O Examples ===\n\n", .{});

    // Create a general purpose allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 1. Basic file operations
    try stdout.print("-- Basic File Operations --\n", .{});
    const test_file_path = "test_file.txt";
    
    // Write a file from scratch
    {
        try stdout.print("Creating and writing to file...\n", .{});
        const file = try std.fs.cwd().createFile(
            test_file_path, 
            .{ .read = true }
        );
        defer file.close();
        
        try file.writeAll("Hello from Zig!\n");
        try file.writeAll("This is line 2.\n");
        try file.writeAll("This is line 3.\n");
        
        try stdout.print("File written successfully.\n", .{});
    }
    
    // Read the entire file at once
    {
        try stdout.print("\nReading entire file at once:\n", .{});
        const file = try std.fs.cwd().openFile(test_file_path, .{});
        defer file.close();
        
        const stat = try file.stat();
        const file_size = stat.size;
        
        const contents = try file.readToEndAlloc(allocator, file_size);
        defer allocator.free(contents);
        
        try stdout.print("File contents ({d} bytes):\n{s}", .{ contents.len, contents });
    }
    
    // Reading file line by line
    {
        try stdout.print("\nReading file line by line:\n", .{});
        const file = try std.fs.cwd().openFile(test_file_path, .{});
        defer file.close();
        
        var buf_reader = std.io.bufferedReader(file.reader());
        var in_stream = buf_reader.reader();
        
        var buf: [1024]u8 = undefined;
        var line_num: usize = 1;
        
        while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
            try stdout.print("Line {d}: {s}\n", .{ line_num, line });
            line_num += 1;
        }
    }

    // 2. Appending to a file
    {
        try stdout.print("\n-- Appending to a File --\n", .{});
        const file = try std.fs.cwd().openFile(test_file_path, .{ .mode = .write_only });
        defer file.close();
        
        // Seek to the end of the file
        try file.seekFromEnd(0);
        
        // Append new content
        try file.writeAll("This line was appended.\n");
        try file.writeAll("And so was this one!\n");
        
        try stdout.print("Content appended to file.\n", .{});
    }
    
    // Read the file again to verify appended content
    {
        try stdout.print("\nFile contents after append:\n", .{});
        const file = try std.fs.cwd().openFile(test_file_path, .{});
        defer file.close();
        
        const stat = try file.stat();
        const contents = try file.readToEndAlloc(allocator, stat.size);
        defer allocator.free(contents);
        
        try stdout.print("{s}", .{contents});
    }

    // 3. File metadata
    {
        try stdout.print("\n-- File Metadata --\n", .{});
        const file = try std.fs.cwd().openFile(test_file_path, .{});
        defer file.close();
        
        const stat = try file.stat();
        
        // Format the file timestamp
        const ts_seconds = @as(f64, @floatFromInt(stat.mtime)) / 1000000000.0;
        
        try stdout.print("File size: {d} bytes\n", .{stat.size});
        try stdout.print("Time of last modification: {d:.6} seconds since epoch\n", .{ts_seconds});
        try stdout.print("File mode: {o}\n", .{stat.mode});
    }

    // 4. Directory operations
    {
        try stdout.print("\n-- Directory Operations --\n", .{});
        
        // Create a temporary directory
        const temp_dir_name = "zig_test_dir";
        
        // First try to remove the directory if it exists from previous runs
        std.fs.cwd().deleteTree(temp_dir_name) catch {};
        
        // Now create a fresh directory
        try std.fs.cwd().makeDir(temp_dir_name);
        try stdout.print("Created directory: {s}\n", .{temp_dir_name});
        
        // Create some files in the directory
        {
            var dir = try std.fs.cwd().openDir(temp_dir_name, .{});
            defer dir.close();
            
            var file1 = try dir.createFile("file1.txt", .{});
            try file1.writeAll("Content of file 1");
            file1.close();
            
            var file2 = try dir.createFile("file2.txt", .{});
            try file2.writeAll("Content of file 2");
            file2.close();
            
            var file3 = try dir.createFile("file3.txt", .{});
            try file3.writeAll("Content of file 3");
            file3.close();
            
            try stdout.print("Created 3 files in the directory.\n", .{});
        }
        
        // List directory contents
        try stdout.print("\nDirectory contents:\n", .{});

        // We'll use a simple approach to manually list the files we created
        const files = [_][]const u8{"file1.txt", "file2.txt", "file3.txt"};
        
        // Open the directory once
        var dir = try std.fs.cwd().openDir(temp_dir_name, .{});
        defer dir.close();
        
        for (files) |filename| {
            // Get file size using the directory handle
            const file = try dir.openFile(filename, .{});
            defer file.close();
            const stat = try file.stat();
            
            try stdout.print("  {s} - file ({d} bytes)\n", .{ 
                filename, 
                stat.size 
            });
        }
        
        // Cleanup the directory and files (uncomment to enable deletion)
        // try std.fs.cwd().deleteTree(temp_dir_name);
        // try stdout.print("\nCleanup: Deleted directory and all contents.\n", .{});
    }

    // 5. Working with paths
    {
        try stdout.print("\n-- Path Operations --\n", .{});
        
        // Get the current working directory
        const cwd_path_buf = try std.process.getCwdAlloc(allocator);
        defer allocator.free(cwd_path_buf);
        try stdout.print("Current working directory: {s}\n", .{cwd_path_buf});
        
        // Join paths
        const joined_path = try std.fs.path.join(allocator, &[_][]const u8{ cwd_path_buf, "subdir", "file.txt" });
        defer allocator.free(joined_path);
        try stdout.print("Joined path: {s}\n", .{joined_path});
        
        // Get basename (filename)
        const basename = std.fs.path.basename(joined_path);
        try stdout.print("Basename: {s}\n", .{basename});
        
        // Get directory name
        const dirname = std.fs.path.dirname(joined_path);
        if (dirname) |dir| {
            try stdout.print("Directory: {s}\n", .{dir});
        }
        
        // Get extension
        const extension = std.fs.path.extension(joined_path);
        try stdout.print("Extension: {s}\n", .{extension});
        
        // Resolve path
        const resolved = try std.fs.path.resolve(allocator, &[_][]const u8{ "../", cwd_path_buf });
        defer allocator.free(resolved);
        try stdout.print("Resolved path: {s}\n", .{resolved});
    }

    try stdout.print("\n=== End of File I/O Examples ===\n", .{});
}
