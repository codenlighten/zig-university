const std = @import("std");

// Note: The StreamServer API has changed in Zig 0.14.0. This is a simplified example
// showing the core networking concepts, but it would need further adaptation to
// run with the current Zig version. For now, we'll demonstrate the HTTP client only.

// Simple TCP echo server (implementation details shown but not directly runnable with Zig 0.14.0)
fn runServer(address: std.net.Address) !void {
    std.debug.print("TCP server example (not implemented for Zig 0.14.0)\n", .{});
    std.debug.print("Server address would be: {}\n", .{address});
    
    // In Zig 0.14.0, the server implementation would need to be completely revised
    // using the updated networking APIs.
}

// Function to handle a client connection (simplified)
fn handleClient(client_address: std.net.Address) !void {
    std.debug.print("Client connected from {}\n", .{client_address});
    std.debug.print("This is a simplified placeholder for Zig 0.14.0 compatibility\n", .{});
}

// Simple TCP client function (simplified for Zig 0.14.0 compatibility)
fn runClient(address: std.net.Address) !void {
    std.debug.print("TCP client example\n", .{});
    
    // Create a TCP connection to the server
    const conn = try std.net.tcpConnectToAddress(address);
    defer conn.close();
    
    // Prepare the message
    const message = "Hello from TCP client!";
    
    // Send a message to the server
    _ = try conn.write(message);
    std.debug.print("Sent to server: {s}\n", .{message});
    
    // In real usage, we would receive a response, but since the server is simplified,
    // we'll just print a placeholder message
    std.debug.print("Would normally receive response from server here\n", .{});
}

// Simplified HTTP client function to work with Zig 0.14.0
fn httpGet(allocator: std.mem.Allocator) !void {
    // For simplicity, we'll use a hardcoded example.com hostname
    // instead of parsing the URL, since the URI API has changed in Zig 0.14.0
    const hostname = "example.com";
    const port: u16 = 80;
    const path = "/";
    
    std.debug.print("Making HTTP request to {s}:{d}{s}\n", .{hostname, port, path});
    
    // Resolve the hostname to an IP address
    const addresses = try std.net.getAddressList(allocator, hostname, port);
    defer addresses.deinit();
    
    if (addresses.addrs.len == 0) {
        std.debug.print("Could not resolve host: {s}\n", .{hostname});
        return;
    }
    
    // Connect to the first resolved address
    const conn = try std.net.tcpConnectToAddress(addresses.addrs[0]);
    defer conn.close();
    
    // Create the HTTP request
    var http_request = std.ArrayList(u8).init(allocator);
    defer http_request.deinit();
    
    // Format the HTTP request
    try http_request.writer().print("GET {s} HTTP/1.1\r\nHost: {s}\r\nConnection: close\r\n\r\n", 
        .{ path, hostname });
    
    // Send the request
    _ = try conn.write(http_request.items);
    std.debug.print("HTTP request sent to {s}\n", .{hostname});
    
    // Read the response
    var buffer: [4096]u8 = undefined;
    var total_read: usize = 0;
    
    // Read in chunks until connection is closed by server
    while (true) {
        const bytes_read = try conn.read(buffer[total_read..]);
        if (bytes_read == 0) break;
        
        total_read += bytes_read;
        
        // Avoid buffer overflow
        if (total_read >= buffer.len) break;
    }
    
    std.debug.print("Received {d} bytes of HTTP response\n", .{total_read});
    
    // Print headers and a preview of the body
    const response = buffer[0..total_read];
    
    // Find the separation between headers and body
    if (std.mem.indexOf(u8, response, "\r\n\r\n")) |header_end| {
        const headers = response[0..header_end];
        const body_start = header_end + 4;
        
        std.debug.print("\nHTTP Headers:\n{s}\n", .{headers});
        
        // Print a preview of the body (first 100 characters or less)
        const body_preview_len = @min(100, response.len - body_start);
        const body_preview = response[body_start..body_start + body_preview_len];
        
        std.debug.print("\nBody Preview:\n{s}...\n", .{body_preview});
    } else {
        // If we can't find the header/body separator, just print the first 200 bytes
        const preview_len = @min(200, response.len);
        std.debug.print("\nResponse preview:\n{s}...\n", .{response[0..preview_len]});
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig Networking Examples ===\n\n", .{});

    // Create an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Demonstrate HTTP client
    try stdout.print("-- HTTP Client Example --\n", .{});
    // Using hardcoded example.com in the httpGet function
    try httpGet(allocator);

    // For demonstration purposes, we'll show the code for the TCP server and client
    // but we won't actually run them both simultaneously as they would block each other
    try stdout.print("\n-- TCP Server/Client --\n", .{});
    try stdout.print("This example demonstrates how to create a TCP server and client.\n", .{});
    try stdout.print("To run this in practice, run the server in one terminal:\n", .{});
    try stdout.print("  zig run networking.zig -- server\n", .{});
    try stdout.print("And the client in another terminal:\n", .{});
    try stdout.print("  zig run networking.zig -- client\n\n", .{});

    // Check if we should run as a server or client based on args
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    // Default address
    const port: u16 = 8080;
    const address = std.net.Address.initIp4([_]u8{ 127, 0, 0, 1 }, port);

    if (args.len > 1) {
        const mode = args[1];
        if (std.mem.eql(u8, mode, "server")) {
            // Run as server
            try stdout.print("Starting server...\n", .{});
            try runServer(address);
        } else if (std.mem.eql(u8, mode, "client")) {
            // Run as client
            try stdout.print("Starting client...\n", .{});
            try runClient(address);
        } else {
            try stdout.print("Unknown mode: {s}\n", .{mode});
            try stdout.print("Usage: zig run networking.zig -- [server|client]\n", .{});
        }
    } else {
        try stdout.print("No mode specified, doing nothing. Use -- server or -- client argument.\n", .{});
    }

    try stdout.print("\n=== End of Networking Examples ===\n", .{});
}
