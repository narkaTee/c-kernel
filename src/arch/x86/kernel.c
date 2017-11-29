#include "lib/vga-buffer.c"


void kernel_main(void) {
    const char *str = "my first 32bit kernel";
    struct screen_char *vidptr = (struct screen_char*)0xb8000; //vga text buffer begins here.
    unsigned int i = 0;
    unsigned int j = 0;

    //Prepare the color code
    struct color_code cc = get_color_code(colorBlack, colorMagenta);

    /* this loops clears the screen
    * there are 25 lines each of 80 columns; each element takes 2 bytes */
    while(j < 80 * 25 * 2) {
        struct screen_char sc = {' ', cc};
        vidptr[j] = sc;
        j = j + 1;
    }

    j = 0;

    /* this loop writes the string to video memory */
    while(str[j] != '\0') {
        //Prep char bytes:
        // 1. char ascii
        // 2. color code
        struct screen_char sc = {str[j], cc};
        vidptr[i] = sc;
        ++j;
        i = i + 1;
    }
    return;
}
