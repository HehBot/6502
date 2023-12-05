char const ADDR[]= {22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52};
char const DATA[] = {39, 41, 43, 45, 47, 49, 51, 53};
#define CLK 2
#define RW 3

void setup()
{
    for (int n = 0; n < 16; ++n)
        pinMode(ADDR[n], INPUT);
    for (int n = 0; n < 8; ++n)
        pinMode(ADDR[n], INPUT);
    pinMode(CLK, INPUT);
    pinMode(RW, INPUT);

    attachInterrupt(digitalPinToInterrupt(CLK), onClock, RISING);
    Serial.begin(57600);
}

void onClock()
{
    unsigned int address = 0;
    for (int n = 0; n < 16; n += 1){
        int b = digitalRead(ADDR[n]) ? 1 : 0;
        Serial.print(b);
        address = (address << 1) + b;
    }
    Serial.print(" - ");
    
    unsigned int data = 0;
    for (int n = 0; n < 8; n += 1){
        int b = digitalRead(DATA[n]) ? 1 : 0;
        Serial.print(b);
        data = (data << 1) + b;
    }

    char output[32];
    sprintf(output, "  --  %04x %c %02x", address, digitalRead(RW) ? 'r' : 'W', data);
    Serial.println(output);
}

void loop()
{
}
