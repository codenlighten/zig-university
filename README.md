# Zig University

## Zig Programming Examples

This repository contains a collection of examples demonstrating various features and capabilities of the Zig programming language (version 0.11.0).

## Overview

These examples showcase Zig's powerful features, from basic memory management to advanced compile-time metaprogramming. Each example is self-contained and comes with explanatory comments.

## Prerequisites

- Zig 0.11.0 or compatible version
- Basic familiarity with programming concepts

## Examples

### 1. Memory Allocators (`01_memory_allocators.zig`)
Demonstrates Zig's various memory allocation strategies:
- General Purpose Allocator
- Arena Allocator
- Fixed Buffer Allocator
- Page Allocator

```bash
zig run 01_memory_allocators.zig
```

### 2. Data Structures (`02_data_structures.zig`)
Showcases common data structures in Zig's standard library:
- ArrayList
- StringHashMap
- AutoHashMap
- BufSet
- SinglyLinkedList

```bash
zig run 02_data_structures.zig
```

### 3. String Formatting (`03_string_formatting.zig`)
Explores string manipulation and formatting capabilities:
- String concatenation
- Formatting with placeholders
- Parsing strings

```bash
zig run 03_string_formatting.zig
```

### 4. File I/O (`04_file_io.zig`)
Demonstrates file operations in Zig:
- Reading and writing files
- Directory operations
- Path manipulation

```bash
zig run 04_file_io.zig
```

### 5. Error Handling (`05_error_handling.zig`)
Showcases Zig's error handling mechanisms:
- Error sets
- Try/catch
- Error unions
- Error return tracing

```bash
zig run 05_error_handling.zig
```

### 6. Testing (`06_testing.zig`)
Demonstrates Zig's built-in testing framework:
- Unit tests
- Test expectation functions
- Test setup and teardown

```bash
zig run 06_testing.zig
# or
zig test 06_testing.zig
```

### 7. Threading (`07_threading.zig`)
Shows threading and concurrency in Zig:
- Thread creation
- Mutexes
- Condition variables
- Thread pools

```bash
zig run 07_threading.zig
```

### 8. JSON Processing (`08_json.zig`)
Demonstrates JSON parsing and generation:
- Parsing JSON strings
- Generating JSON from data
- Working with JSON objects and arrays

```bash
zig run 08_json.zig
```

### 9. Networking (`09_networking.zig`)
Implements basic networking functionality:
- TCP server and client
- Socket programming
- Asynchronous I/O

```bash
zig run 09_networking.zig
```

### 10. Compile-Time Features (`10_comptime_features.zig`)
Explores Zig's powerful compile-time metaprogramming:
- Compile-time function execution
- Type reflection
- Generic data structures
- Type-based specialization

```bash
zig run 10_comptime_features.zig
```

### 11. Cryptography (`11_cryptography.zig`)
Shows cryptographic capabilities:
- Hash functions (SHA-256, SHA-512, Blake2, Blake3)
- HMAC for message authentication
- Password hashing
- Symmetric encryption
- Secure random number generation

```bash
zig run 11_cryptography.zig
```

### 12. Build System (`12_build_system/`)
Demonstrates Zig's build system for larger projects:
- Multi-file projects
- Dependencies
- Custom build steps
- Testing integration

```bash
cd 12_build_system
zig build
zig build run
zig build test
```

### 13. Foreign Function Interface (FFI) (`13_ffi/`)
Shows Zig's seamless interoperability with C:
- Calling C functions from Zig
- Working with C structs
- Memory management across the FFI boundary
- String conversion between C and Zig

```bash
cd 13_ffi
zig build run
```

## Learning Resources

Two key documentation files are included:
- `overview.md` - A comprehensive overview of Zig's standard library
- `additional.md` - Additional reference material for the Zig language

## Key Features of Zig

- Manual memory management with advanced allocator design
- Compile-time metaprogramming
- Error handling as a first-class language feature
- C ABI compatibility and seamless FFI
- Performance and safety focused design
- Cross-compilation capabilities
- Powerful build system

## Contribution

Feel free to add more examples or improve existing ones!

## License

This project is available under the MIT License - see the LICENSE file for details.
