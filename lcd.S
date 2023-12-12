PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003

    .org $8000

reset:
    ldx #$ff         ; Set stack register
    txs

    jsr lcd_init
    jsr puts

loop:
    jmp loop

message: .asciiz "   Learn more                            eater.net/6502"

; initialise lcd (D0-D7 connected to PORTB and E,RS,RWB to 3 msb of PORTA)
E   = %10000000
RWB = %01000000
RS  = %00100000
lcd_init:
    pha
    lda #%11111111   ; Set all pins on port B to output
    sta DDRB
    lda #%11100000   ; Set top 3 pins on port A to output
    sta DDRA

    lda #%00111000   ; Set 8-bit mode, 2-line display, 5x8 character font
    jsr lcd_instruction
    lda #%00001110   ; Display on, cursor on, blink off
    jsr lcd_instruction
    lda #%00000110   ; Increment and shift cursor, dont shift display
    jsr lcd_instruction
    lda #%00000001   ; Clear display
    jsr lcd_instruction
    pla
    rts

lcd_instruction:
    jsr lcd_wait
    sta PORTB
    lda #0           ; Clear RS/RWB/E bits
    sta PORTA
    lda #E           ; Set E bit to send instruction
    sta PORTA
    lda #0           ; Clear RS/RWB/E bits
    sta PORTA
    rts

lcd_wait:
    pha
    lda #%00000000   ; Set port B to input
    sta DDRB
.busy:
    lda #RWB
    sta PORTA
    lda #(RWB | E)
    sta PORTA
    lda PORTB
    and #%10000000
    bne .busy

    lda #RWB
    sta PORTA
    lda #%11111111   ; Set port B to output
    sta DDRB
    pla
    rts

; put character in A register to lcd
putc:
    pha
    jsr lcd_wait
    sta PORTB
    lda #RS          ; Set RS, Clear RWB/E bits
    sta PORTA
    lda #(RS | E)    ; Set E bit to send instruction
    sta PORTA
    lda #RS          ; Clear RWB/E bits
    sta PORTA
    pla
    rts

; put null-terminated string at `message` to lcd
puts:
    pha
    ldx #0
.loop:
    lda message, x
    beq .end
    jsr putc
    inx
    jmp .loop
.end:
    pla
    rts
