#include "c_library.h"

// Basic math function
int32_t add_numbers(int32_t a, int32_t b) {
    return a + b;
}

// String manipulation
char* concatenate_strings(const char* str1, const char* str2) {
    if (!str1 || !str2) return NULL;
    
    size_t len1 = strlen(str1);
    size_t len2 = strlen(str2);
    
    // Allocate memory for the concatenated string (plus null terminator)
    char* result = (char*)malloc(len1 + len2 + 1);
    
    if (result) {
        strcpy(result, str1);
        strcat(result, str2);
    }
    
    return result;
}

// Function that works with our custom struct
void initialize_item(Item* item, int32_t id, const char* name, double value) {
    if (!item || !name) return;
    
    item->id = id;
    
    // Safely copy the name (preventing buffer overflow)
    strncpy(item->name, name, sizeof(item->name) - 1);
    item->name[sizeof(item->name) - 1] = '\0';
    
    item->value = value;
}

// Function that prints item details
void print_item(const Item* item) {
    if (!item) return;
    
    printf("Item(id=%d, name='%s', value=%f)\n", 
           item->id, item->name, item->value);
}

// Create a collection with allocated memory
Collection* create_collection(const char* title, size_t item_count) {
    if (!title) return NULL;
    
    // Allocate the collection structure
    Collection* collection = (Collection*)malloc(sizeof(Collection));
    if (!collection) return NULL;
    
    // Allocate and copy the title (manual implementation of strdup for C99 compatibility)
    size_t title_len = strlen(title);
    collection->title = (char*)malloc(title_len + 1);
    if (!collection->title) {
        free(collection);
        return NULL;
    }
    strcpy(collection->title, title);
    
    // Allocate array of items
    collection->items = (Item*)calloc(item_count, sizeof(Item));
    if (!collection->items) {
        free(collection->title);
        free(collection);
        return NULL;
    }
    
    collection->item_count = item_count;
    
    // Initialize each item with default values
    for (size_t i = 0; i < item_count; i++) {
        char default_name[20];
        sprintf(default_name, "Item %zu", i + 1);
        initialize_item(&collection->items[i], (int32_t)i, default_name, 0.0);
    }
    
    return collection;
}

// Free a collection and all its resources
void free_collection(Collection* collection) {
    if (!collection) return;
    
    // Free the title string
    free(collection->title);
    
    // Free the items array
    free(collection->items);
    
    // Free the collection itself
    free(collection);
}
