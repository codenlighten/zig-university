const std = @import("std");

// Define a struct that will be serialized to/from JSON
const Person = struct {
    name: []const u8,
    age: u32,
    is_employed: bool,
    address: ?Address = null,
    tags: []const []const u8 = &[_][]const u8{},

    // Nested struct for address
    const Address = struct {
        street: []const u8,
        city: []const u8,
        zip: []const u8,
    };
};

// Define a struct with custom parsing for a more complex example
const Config = struct {
    server: ServerConfig,
    database: DatabaseConfig,
    logging: LoggingConfig,
    features: Features,

    const ServerConfig = struct {
        host: []const u8,
        port: u16,
        max_connections: u32 = 100,
        timeout_seconds: u32 = 30,
    };

    const DatabaseConfig = struct {
        url: []const u8,
        max_pool_size: u32 = 10,
        timeout_seconds: u32 = 5,
    };

    const LoggingConfig = struct {
        level: []const u8 = "info",
        file: ?[]const u8 = null,
    };

    const Features = struct {
        enable_auth: bool = true,
        enable_cache: bool = true,
        enable_metrics: bool = false,
        cache_ttl_seconds: u32 = 300,
    };
};

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig JSON Parsing and Generation Examples ===\n\n", .{});

    // Create an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 1. Parse a simple JSON string
    try stdout.print("-- Parsing Simple JSON --\n", .{});
    const simple_json = 
        \\{
        \\  "name": "Alice",
        \\  "age": 32,
        \\  "is_employed": true,
        \\  "tags": ["developer", "musician"]
        \\}
    ;

    // Parse the JSON string into a dynamic JSON value
    var parsed_json = try std.json.parseFromSlice(std.json.Value, allocator, simple_json, .{});
    defer parsed_json.deinit();

    // Access values from the parsed JSON
    const root = parsed_json.value;
    if (root != .object) {
        try stdout.print("Root is not an object\n", .{});
        return;
    }

    const name = root.object.get("name") orelse {
        try stdout.print("Name not found\n", .{});
        return;
    };
    
    if (name != .string) {
        try stdout.print("Name is not a string\n", .{});
        return;
    }

    const age = root.object.get("age") orelse {
        try stdout.print("Age not found\n", .{});
        return;
    };
    
    if (age != .integer) {
        try stdout.print("Age is not an integer\n", .{});
        return;
    }

    const is_employed = root.object.get("is_employed") orelse {
        try stdout.print("is_employed not found\n", .{});
        return;
    };
    
    if (is_employed != .bool) {
        try stdout.print("is_employed is not a boolean\n", .{});
        return;
    }

    try stdout.print("Name: {s}\n", .{name.string});
    try stdout.print("Age: {d}\n", .{age.integer});
    try stdout.print("Employed: {}\n", .{is_employed.bool});

    // Access array elements
    if (root.object.get("tags")) |tags| {
        if (tags == .array) {
            try stdout.print("Tags: [", .{});
            
            for (tags.array.items, 0..) |tag, i| {
                if (tag == .string) {
                    if (i > 0) try stdout.print(", ", .{});
                    try stdout.print("{s}", .{tag.string});
                }
            }
            
            try stdout.print("]\n", .{});
        }
    }

    try stdout.print("\n", .{});

    // 2. Parse JSON directly into a struct
    try stdout.print("-- Parsing JSON to Struct --\n", .{});
    const person_json = 
        \\{
        \\  "name": "Bob",
        \\  "age": 28,
        \\  "is_employed": false,
        \\  "address": {
        \\    "street": "123 Main St",
        \\    "city": "Anytown",
        \\    "zip": "12345"
        \\  },
        \\  "tags": ["artist", "writer"]
        \\}
    ;

    // Parse JSON directly into our Person struct
    var person = try std.json.parseFromSlice(Person, allocator, person_json, .{});
    defer person.deinit();

    // Access the parsed data through the struct
    try stdout.print("Person name: {s}\n", .{person.value.name});
    try stdout.print("Person age: {d}\n", .{person.value.age});
    try stdout.print("Person employed: {}\n", .{person.value.is_employed});
    
    if (person.value.address) |addr| {
        try stdout.print("Address: {s}, {s} {s}\n", .{ 
            addr.street, 
            addr.city, 
            addr.zip 
        });
    }
    
    if (person.value.tags.len > 0) {
        try stdout.print("Tags: [", .{});
        for (person.value.tags, 0..) |tag, i| {
            if (i > 0) try stdout.print(", ", .{});
            try stdout.print("{s}", .{tag});
        }
        try stdout.print("]\n", .{});
    }

    try stdout.print("\n", .{});

    // 3. Generate JSON from a struct
    try stdout.print("-- Generating JSON from Struct --\n", .{});
    
    // Create a person struct
    const address = Person.Address{
        .street = "456 Elm St",
        .city = "Somewhere",
        .zip = "67890",
    };
    
    const charlie = Person{
        .name = "Charlie",
        .age = 45,
        .is_employed = true,
        .address = address,
        .tags = &[_][]const u8{"engineer", "parent", "hiker"},
    };
    
    // Convert the struct to JSON
    // In Zig 0.14.0, we'll use default options
    try stdout.print("Person as JSON:\n", .{});
    try std.json.stringify(charlie, .{}, stdout);
    try stdout.print("\n\n", .{});

    // 4. Working with more complex JSON
    try stdout.print("-- Working with Complex JSON --\n", .{});
    const config_json = 
        \\{
        \\  "server": {
        \\    "host": "localhost",
        \\    "port": 8080,
        \\    "max_connections": 200
        \\  },
        \\  "database": {
        \\    "url": "postgres://user:pass@localhost:5432/mydb",
        \\    "max_pool_size": 20
        \\  },
        \\  "logging": {
        \\    "level": "debug",
        \\    "file": "/var/log/app.log"
        \\  },
        \\  "features": {
        \\    "enable_auth": true,
        \\    "enable_cache": true, 
        \\    "enable_metrics": true,
        \\    "cache_ttl_seconds": 600
        \\  }
        \\}
    ;
    
    var config = try std.json.parseFromSlice(Config, allocator, config_json, .{});
    defer config.deinit();
    
    // Access the parsed configuration
    try stdout.print("Server: {s}:{d} (max conn: {d})\n", .{
        config.value.server.host,
        config.value.server.port,
        config.value.server.max_connections,
    });
    
    try stdout.print("Database URL: {s}\n", .{config.value.database.url});
    
    try stdout.print("Logging level: {s}\n", .{config.value.logging.level});
    if (config.value.logging.file) |log_file| {
        try stdout.print("Log file: {s}\n", .{log_file});
    }
    
    try stdout.print("Features enabled:\n", .{});
    try stdout.print("  Auth: {}\n", .{config.value.features.enable_auth});
    try stdout.print("  Cache: {} (TTL: {d}s)\n", .{
        config.value.features.enable_cache,
        config.value.features.cache_ttl_seconds,
    });
    try stdout.print("  Metrics: {}\n", .{config.value.features.enable_metrics});

    try stdout.print("\n", .{});

    // 5. Modify and save JSON
    try stdout.print("-- Modifying and Saving JSON --\n", .{});
    
    // Create a mutable JSON value
    var obj = std.json.Value{ 
        .object = std.json.ObjectMap.init(allocator) 
    };
    // Note: In Zig 0.14.0, we need to manually free the memory
    
    // Add fields to the JSON object
    try obj.object.put("name", std.json.Value{ .string = "Dave" });
    try obj.object.put("age", std.json.Value{ .integer = 38 });
    try obj.object.put("is_employed", std.json.Value{ .bool = true });
    
    // Add a nested object
    var hobbies = std.json.Value{ 
        .array = std.json.Array.init(allocator) 
    };
    
    try hobbies.array.append(std.json.Value{ .string = "gaming" });
    try hobbies.array.append(std.json.Value{ .string = "cooking" });
    try hobbies.array.append(std.json.Value{ .string = "gardening" });
    
    try obj.object.put("hobbies", hobbies);
    
    // Print the resulting JSON
    try stdout.print("Modified JSON:\n", .{});
    try std.json.stringify(obj, .{}, stdout);
    try stdout.print("\n\n", .{});

    try stdout.print("=== End of JSON Examples ===\n", .{});
}
