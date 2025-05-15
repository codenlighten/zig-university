#ifndef C_LIBRARY_H
#define C_LIBRARY_H

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// A simple struct to demonstrate struct compatibility
typedef struct {
    int32_t id;
    char name[64];
    double value;
} Item;

// A more complex struct with pointer members
typedef struct {
    char* title;
    Item* items;
    size_t item_count;
} Collection;

// Basic math function
int32_t add_numbers(int32_t a, int32_t b);

// String manipulation
char* concatenate_strings(const char* str1, const char* str2);

// Function that works with our custom struct
void initialize_item(Item* item, int32_t id, const char* name, double value);

// Function that prints item details
void print_item(const Item* item);

// Create a collection with allocated memory that the caller must free
Collection* create_collection(const char* title, size_t item_count);

// Free a collection and all its resources
void free_collection(Collection* collection);

#endif /* C_LIBRARY_H */
