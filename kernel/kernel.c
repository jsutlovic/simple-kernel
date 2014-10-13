#include "../drivers/screen.h"

void main() {
    // Create a pointer to a char, and point it to the first text cell of
    // video memory (i.e. the top-left of the screen)
    //char* video_memory = (char*) 0xb8000;
    // At the address to by video_memory, store the character 'X'
    // (i.e. display 'X' in the top-left of the scren).
    //*video_memory = 'Y';

    clear_screen();
    char* msg =
        "Hello, world!\n"
        "This is a test\n"
        "Of being able to print to the screen!\n"
        "From my own 32-bit C kernel\n"
        "Booted from 16-bit real mode\n"
        "With an x86 assembly bootloader\n"
        "\n"
        "\0";
    print(msg);

    char* msg2 = "Test\n\0";
    for (int i = 0; i<20; i++) {
        print(msg2);
    }
}
