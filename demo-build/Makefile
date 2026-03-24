CC=gcc
CFLAGS=-O2 -Wall
TARGET=demo

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) main.c -o $(TARGET)

clean:
	rm -f $(TARGET)
