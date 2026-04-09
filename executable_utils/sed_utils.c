/**
 * @file    replace_text.c
 * @brief   Windows executable utility for replacing text inside files.
 *
 * @details
 * This program provides a command-line utility to search and replace
 * text within a specified file. It is designed to work on Windows
 * systems and can be built using CMake with GCC (MinGW).
 *
 * Features:
 *  - Replace specific text patterns inside files
 *  - Safe file handling
 *  - Windows-compatible implementation
 *
 * Build System:
 *  - CMake
 *  - GCC (MinGW or equivalent)
 *
 * Usage Example:
 *  replace_text.exe <input_file> <search_text> <replace_text>
 *
 * Copyright (c) 2026
 * Yohanes Oktanio
 *
 * Licensed under MIT License
 */

#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define BUFFER_SIZE 8192

void print_usage(const char *prog) {
    printf("Usage:\n");
    printf("  %s <input_template> <output_file> --replace OLD1 NEW1 [--replace OLD2 NEW2 ...]\n", prog);
}

int replace_in_file(const char *src_file, const char *dest_file, int argc, char *argv[]) {
    FILE *input = fopen(src_file, "rb");
    if (!input) {
        perror("Failed to open input file");
        return 1;
    }

    FILE *output = fopen(dest_file, "wb");
    if (!output) {
        perror("Failed to create output file");
        fclose(input);
        return 1;
    }

    char buffer[BUFFER_SIZE];
    while (fgets(buffer, sizeof(buffer), input)) {
        // Apply all replacements to the current line
        for (int i = 3; i < argc; i++) {
            if (strcmp(argv[i], "--replace") == 0 && (i + 2) < argc) {
                const char *old_text = argv[i+1];
                const char *new_text = argv[i+2];

                char line_buffer[BUFFER_SIZE];
                char *pos;
                char *current_pos = buffer;
                line_buffer[0] = '\0';

                while ((pos = strstr(current_pos, old_text)) != NULL) {
                    strncat(line_buffer, current_pos, pos - current_pos);
                    strcat(line_buffer, new_text);
                    current_pos = pos + strlen(old_text);
                }
                strcat(line_buffer, current_pos);
                strcpy(buffer, line_buffer);
                i += 2; // Skip OLD and NEW
            }
        }
        fputs(buffer, output);
    }

    fclose(input);
    fclose(output);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 6) {
        print_usage(argv[0]);
        return 1;
    }

    const char *src_file = argv[1];
    const char *dest_file = argv[2];

    if (replace_in_file(src_file, dest_file, argc, argv) != 0) {
        fprintf(stderr, "Processing failed\n");
        return 1;
    }

    printf("Success: %s -> %s\n", src_file, dest_file);
    return 0;
}