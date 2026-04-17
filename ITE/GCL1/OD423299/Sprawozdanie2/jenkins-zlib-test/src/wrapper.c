#include <stdio.h>
#include <stdlib.h>
#include <zlib.h>

#define BUF_SIZE 16384

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Użycie: %s <plik.gz>\n", argv[0]);
        return 1;
    }

    gzFile file = gzopen(argv[1], "rb");
    if (!file) {
        fprintf(stderr, "Błąd: Nie można otworzyć pliku %s\n", argv[1]);
        return 1;
    }

    unsigned char buffer[BUF_SIZE];
    int uncompressed_bytes;

    while ((uncompressed_bytes = gzread(file, buffer, sizeof(buffer))) > 0) {
        if (fwrite(buffer, 1, uncompressed_bytes, stdout) != (size_t)uncompressed_bytes) {
            fprintf(stderr, "Błąd zapisu danych wyjściowych\n");
            gzclose(file);
            return 1;
        }
    }

    if (uncompressed_bytes < 0) {
        int err;
        fprintf(stderr, "Błąd dekompresji: %s\n", gzerror(file, &err));
    }

    gzclose(file);
    return 0;
}