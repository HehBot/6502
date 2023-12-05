#define SHIFT_DATA 2
#define SHIFT_CLK 3
#define SHIFT_LATCH 4

#define EEPROM_D0 5
#define EEPROM_D7 12
#define WRITE_EN 13

void setAddress(int address, bool output_enable)
{
    shiftOut(SHIFT_DATA, SHIFT_CLK, MSBFIRST, address >> 8 | (output_enable ? 0x00 : 0x80));
    shiftOut(SHIFT_DATA, SHIFT_CLK, MSBFIRST, address & 0xff);

    digitalWrite(SHIFT_LATCH, LOW);
    digitalWrite(SHIFT_LATCH, HIGH);
    digitalWrite(SHIFT_LATCH, LOW);

}

byte readEEPROM(int address)
{
    setAddress(address, true);
    byte data;
    for (int pin = EEPROM_D7; pin >= EEPROM_D0; --pin)
        data = (data << 1) + digitalRead(pin);
    return data;
}
void printContents(int start, int end)
{
    // output is enabled after pinmodes are set
    for (int pin = EEPROM_D0; pin <= EEPROM_D7; ++pin)
        pinMode(pin, INPUT);
    setAddress(0, true);

    for (int b = start; b <= end; ++b) {
        byte data[16];
        int base = b << 4;
        for (int offset = 0; offset <= 15; ++offset)
            data[offset] = readEEPROM(base + offset);

        char buf[80];
        sprintf(buf, "%03x:  %02x %02x %02x %02x %02x %02x %02x %02x  %02x %02x %02x %02x %02x %02x %02x %02x", base << 4, data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7], data[8], data[9], data[10], data[11], data[12], data[13], data[14], data[15]);

        Serial.println(buf);
    }
}

void writeEEPROM(int address, byte data)
{
    setAddress(address, false);
    for (int pin = EEPROM_D0; pin <= EEPROM_D7; ++pin) {
        digitalWrite(pin, data & 1);
        data >>= 1;
    }
    digitalWrite(WRITE_EN, LOW);
    delayMicroseconds(1);
    digitalWrite(WRITE_EN, HIGH);
    delay(10);
}
void writeBuf(int address, byte array[], int sz)
{
    // output is disabled before pinmodes are set
    setAddress(0, false);
    for (int pin = EEPROM_D0; pin <= EEPROM_D7; ++pin)
        pinMode(pin, OUTPUT);
    for (int i = 0; i < sz; ++i)
        writeEEPROM(address + i, array[i]);
}

void setup()
{
    digitalWrite(WRITE_EN, HIGH);
    pinMode(WRITE_EN, OUTPUT);

    pinMode(SHIFT_DATA, OUTPUT);
    pinMode(SHIFT_CLK, OUTPUT);
    pinMode(SHIFT_LATCH, OUTPUT);

    Serial.begin(57600);

    Serial.println("Original contents:");
    printContents(0x00, 0x0f);
#include "program.h"
    writeBuf(0x00, program, sizeof(program));
    Serial.println("New contents:");
    printContents(0x00, 0x0f);

    Serial.println("Writing reset vector:");
    byte reset_vector[] = { 0x00, 0x80 };
    writeBuf(0x7ffc, reset_vector, 2);
    printContents(0x7ff, 0x7ff);
}

void loop()
{
}
