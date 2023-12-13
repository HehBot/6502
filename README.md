# 6502

Following [Ben Eater's 6502 series](https://eater.net/6502)

## Requirements
 - 6502 computer
 - EEPROM programmer

## Usage
To use the Arduino Nano EEPROM programmer (adapted from [this](https://youtu.be/K88pgWhEb1M)) to load `program.S` into the ROM,
```
export EEPROM_DEV="/dev/ttyUSB0"    # replace this with the character device the Arduino Nano is connected on
sudo chown $(whoami) ${EEPROM_DEV}
make program
minicom -D ${EEPROM_DEV} -b 57600   # to verify over Serial that the data was written
```

To use the Arduino Mega processor monitor,
```
export MONITOR_DEV="/dev/ttyACM0"   # replace this with the character device the Arduino Mega is connected on
sudo chown $(whoami) ${MONITOR_DEV}
make monitor    # uploads monitor sketch to Arduino Mega, only needs to be done once
minicom -D ${MONITOR_DEV} -b 57600  # Serial monitor
```

## Links
 - Dr. Volker Barthelmann's assembler [`vasm`](http://www.compilers.de/vasm.html)
