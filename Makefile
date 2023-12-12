ASM		= ./util/vasm6502_oldstyle
ARDU	= arduino-cli

EEPROM	= eeprom_programmer
MONITOR	= monitor

# env vars EEPROM_DEV, MONITOR_DEV need to be set
EEPROM_FQBN		= arduino:avr:nano:cpu=atmega328old
MONITOR_FQBN	= arduino:avr:mega

ASMFLAGS=-Fbin -dotdir

BUILD_DIR	= build

VERIFY_DEV 	= ./util/verify_dev
MAKE_HDR	= ./util/make_hdr

monitor:
	@$(VERIFY_DEV) MONITOR_DEV
	$(ARDU) compile -b $(MONITOR_FQBN) $(MONITOR)
	$(ARDU) upload -b $(MONITOR_FQBN) -p $(MONITOR_DEV) $(MONITOR)

program: %: $(BUILD_DIR)/%.h
	@$(RM) -rf $(EEPROM)/program.h
	@cd $(EEPROM) && ln -s ../$< program.h
	$(ARDU) compile -b $(EEPROM_FQBN) $(EEPROM)
	@$(VERIFY_DEV) EEPROM_DEV
	$(ARDU) upload -b $(EEPROM_FQBN) -p $(EEPROM_DEV) $(EEPROM)

$(BUILD_DIR)/%.h: $(BUILD_DIR)/%.bin
	@$(MAKE_HDR) $< > $@

$(BUILD_DIR)/%.bin: %.S
	@mkdir -p $(dir $@)
	$(ASM) $(ASMFLAGS) -o $@ $<

.PHONY: clean monitor program

clean:
	@$(RM) -rf $(BUILD_DIR)
