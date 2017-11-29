#include <stdint.h>

//Prepare color nibles
static const uint8_t colorBlack      = 0x0u;
static const uint8_t colorBlue       = 0x1u;
static const uint8_t colorGreen      = 0x2u;
static const uint8_t colorCyan       = 0x3u;
static const uint8_t colorRed        = 0x4u;
static const uint8_t colorMagenta    = 0x5u;
static const uint8_t colorBrown      = 0x6u;
static const uint8_t colorLightGray  = 0x7u;
static const uint8_t colorDarkGray   = 0x8u;
static const uint8_t colorLightBlue  = 0x9u;
static const uint8_t colorLightGreen = 0xAu;
static const uint8_t colorLightCyan  = 0xBu;
static const uint8_t colorLightRed   = 0xCu;
static const uint8_t colorPink       = 0xDu;
static const uint8_t colorYellow     = 0xEu;
static const uint8_t colorWhite      = 0xFu;

struct color_code {
    uint8_t color;
};

// bits 0-7: ascii char
// bits 8-11: foreground color
// bits 12-14: background color
// bit 15: blink
struct screen_char {
    uint8_t ascii;
    struct color_code c;
};

struct color_code get_color_code(uint8_t fg,uint8_t bg) {
    // the bits are: bbbbffff
    // we only want the first 4 bits, the or below could overflow
    fg = fg & 0xF;
    bg = bg & 0xF; // bg cann actually only be 3 bit long (0-8), the last bit is used for blink
    // Shift the bg color left by 4 bit and OR it with the fg.
    struct color_code cc = {bg << 4 | fg};
    return cc;
}
