const std = @import("std");

// A structure to pass to our worker threads
const WorkerContext = struct {
    id: usize,
    iterations: usize,
    result: std.atomic.Value(usize),

    pub fn init(id: usize, iterations: usize) WorkerContext {
        return .{
            .id = id,
            .iterations = iterations,
            .result = std.atomic.Value(usize).init(0),
        };
    }
};

// The worker thread function
fn workerFunction(context: *WorkerContext) void {
    // Print that the thread is starting
    std.debug.print("Thread {d} starting with {d} iterations\n", .{ 
        context.id, 
        context.iterations 
    });

    // Do some "work" - just a simple loop with a sleep
    var sum: usize = 0;
    for (0..context.iterations) |i| {
        // Simulate work with a small sleep
        std.time.sleep(std.time.ns_per_ms * 5);
        sum += i;
    }

    // Save the result atomically
    context.result.store(sum, .release);

    // Print that the thread is done
    std.debug.print("Thread {d} finished, result: {d}\n", .{ context.id, sum });
}

// Function demonstrating a mutex
fn mutexExample() !void {
    std.debug.print("\n-- Mutex Example --\n", .{});

    // Create a mutex
    var mutex = std.Thread.Mutex{};
    
    // Shared resource
    var shared_counter: usize = 0;
    
    // Create threads that will modify the shared resource
    const thread_count = 5;
    
    var threads: [thread_count]std.Thread = undefined;
    
    // Start the threads
    for (0..thread_count) |i| {
        threads[i] = try std.Thread.spawn(.{}, struct {
            fn threadFn(id: usize, mtx: *std.Thread.Mutex, counter: *usize) void {
                // Perform several operations
                for (0..10) |_| {
                    // Sleep to introduce randomness
                    std.time.sleep(std.time.ns_per_ms * @as(u64, @intCast((id * 2 + 3))));
                    
                    // Lock the mutex before accessing the shared resource
                    mtx.lock();
                    defer mtx.unlock(); // Make sure we unlock even if there's an error
                    
                    // Update the shared counter while mutex is locked
                    counter.* += 1;
                    std.debug.print("Thread {d} incremented counter to {d}\n", .{ id, counter.* });
                }
            }
        }.threadFn, .{ i, &mutex, &shared_counter });
    }
    
    // Wait for all threads to complete
    for (threads) |thread| {
        thread.join();
    }
    
    std.debug.print("Final counter value: {d}\n", .{shared_counter});
}

// Function demonstrating condition variables
fn conditionVariableExample() !void {
    std.debug.print("\n-- Condition Variable Example --\n", .{});
    
    // Create a condition variable
    var cond = std.Thread.Condition{};
    var mutex = std.Thread.Mutex{};
    
    // Shared state
    var data_ready = false;
    var data: usize = 0;
    
    // Create a producer thread
    const producer = try std.Thread.spawn(.{}, struct {
        fn threadFn(mtx: *std.Thread.Mutex, cv: *std.Thread.Condition, 
                    ready: *bool, value: *usize) void {
            std.debug.print("Producer: Starting\n", .{});
            
            // Simulate work
            std.time.sleep(std.time.ns_per_s * 2);
            
            // Update the shared data
            mtx.lock();
            defer mtx.unlock();
            
            value.* = 42;
            ready.* = true;
            std.debug.print("Producer: Data is ready (value={d})\n", .{value.*});
            
            // Signal the condition variable
            cv.signal();
        }
    }.threadFn, .{ &mutex, &cond, &data_ready, &data });
    
    // Create consumer threads
    const consumer_count = 3;
    var consumers: [consumer_count]std.Thread = undefined;
    
    for (0..consumer_count) |i| {
        consumers[i] = try std.Thread.spawn(.{}, struct {
            fn threadFn(id: usize, mtx: *std.Thread.Mutex, cv: *std.Thread.Condition, 
                        ready: *bool, value: *usize) void {
                std.debug.print("Consumer {d}: Waiting for data\n", .{id});
                
                // Wait for the condition variable
                mtx.lock();
                while (!ready.*) {
                    cv.wait(mtx);
                }
                const local_data = value.*;
                mtx.unlock();
                
                std.debug.print("Consumer {d}: Received data value={d}\n", .{ id, local_data });
            }
        }.threadFn, .{ i, &mutex, &cond, &data_ready, &data });
    }
    
    // Wait for all threads to complete
    producer.join();
    for (consumers) |consumer| {
        consumer.join();
    }
}

// Note: Thread Pool API has changed significantly in Zig 0.14.0
// For a simpler example, we've removed the ThreadPool demonstration

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("\n=== Zig Concurrency and Threading Examples ===\n\n", .{});

    // Create an allocator
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    // 1. Basic threading example
    try stdout.print("-- Basic Threading Example --\n", .{});
    
    // Create worker contexts
    const worker_count = 4;
    var contexts: [worker_count]WorkerContext = undefined;
    
    for (0..worker_count) |i| {
        contexts[i] = WorkerContext.init(i + 1, (i + 1) * 50);
    }
    
    // Create and start the threads
    var threads: [worker_count]std.Thread = undefined;
    
    for (0..worker_count) |i| {
        threads[i] = try std.Thread.spawn(.{}, workerFunction, .{&contexts[i]});
    }
    
    // Wait for all threads to finish
    for (threads) |thread| {
        thread.join();
    }
    
    // Print the results
    try stdout.print("\nResults from all threads:\n", .{});
    var total: usize = 0;
    
    for (0..worker_count) |i| {
        const result = contexts[i].result.load(.acquire);
        total += result;
        try stdout.print("Thread {d} result: {d}\n", .{ i + 1, result });
    }
    
    try stdout.print("Total of all results: {d}\n", .{total});
    
    // 2. Mutex example
    try mutexExample();
    
    // 3. Condition variable example
    try conditionVariableExample();
    
    // Thread pool API has changed in Zig 0.14.0, so we've omitted that example

    try stdout.print("\n=== End of Threading Examples ===\n", .{});
}
