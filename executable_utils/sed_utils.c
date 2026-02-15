#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define BUFFER_SIZE 4096

void print_usage(const char *prog) {
    printf("Usage:\n");
    printf("  %s <old_file> <new_file> [--replace OLD NEW]\n", prog);
}

int replace_in_file(const char *filename, const char *old, const char *new_text) {
    FILE *input = fopen(filename, "rb");
    if (!input) {
        perror("Failed to open input file");
        return 1;
    }
    char temp_name[1024];
    tmpnam(temp_name);

    FILE *output = fopen(temp_name, "wb");
    if (!output) {
        perror("Failed to create temp file");
        fclose(input);
        return 1;
    }

    char buffer[BUFFER_SIZE];

    while (fgets(buffer, sizeof(buffer), input)) {
        char *pos;
        while ((pos = strstr(buffer, old)) != NULL) {
            *pos = '\0';
            fputs(buffer, output);
            fputs(new_text, output);
            memmove(buffer, pos + strlen(old),
                    strlen(pos + strlen(old)) + 1);
        }
        fputs(buffer, output);
    }

    fclose(input);
    fclose(output);

    remove(filename);
    rename(temp_name, filename);
    return 0;
}

int main(int argc, char *argv[]) {

    if (argc < 3) {
        print_usage(argv[0]);
        return 1;
    }

    const char *old_file = argv[1];
    const char *new_file = argv[2];

    if (argc == 6 && strcmp(argv[3], "--replace") == 0) {
        if (replace_in_file(old_file, argv[4], argv[5]) != 0) {
            return 1;
        }
    }

    if (rename(old_file, new_file) != 0) {
        fprintf(stderr, "Rename failed: %s\n", strerror(errno));
        return 1;
    }

    printf("Success: %s -> %s\n", old_file, new_file);
    return 0;
}