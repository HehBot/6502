PORTB = $6000
PORTA = $6001
DDRB  = $6002
DDRA  = $6003
PCR   = $600c
IFR   = $600d
IER   = $600e

value = $0200   ; 2 bytes
mod10 = $0202   ; 2 bytes
message = $0204 ; 6 bytes
counter = $020a ; 2 bytes

    .org $8000
start:
    ldx #$ff         ; Set stack register
    txs
    cli

    lda #$82
    sta IER
    lda #$00
    sta PCR

    jsr lcd_init
    lda #0
    sta counter
    sta counter + 1

loop:
    lda #%00000010   ; Home cursor
    jsr lcd_instruction

    lda #0
    sta message

    ; initialise value to counter
    sei
    lda counter
    sta value
    lda counter + 1
    sta value + 1
    cli

.divide:
    ; initialise remainder to zero
    lda #0
    sta mod10
    sta mod10 + 1
    clc

    ldx #16
.divloop:
    ; rotate quotient and remainder
    rol value
    rol value + 1
    rol mod10
    rol mod10 + 1

    sec
    lda mod10
    sbc #10
    tay
    lda mod10 + 1
    sbc #0
    bcc .ignore_result
    sty mod10
    sta mod10 + 1

.ignore_result:
    dex
    bne .divloop
    rol value
    rol value + 1

    lda mod10
    clc
    adc #"0"
    jsr push_char

    ; if value != 0, then continue dividing
    lda value
    ora value + 1
    bne .divide

    jsr puts

    jmp loop

;;

; add the character in the A register to the beginning of the null-terminated string `message`
push_char:
    pha
    ldy #0
.loop:
    lda message,y
    tax
    pla
    sta message, y
    iny
    txa
    pha
    bne .loop

    pla
    sta message, y
    rts

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

nmi:
irq:
    inc counter
    bne .end
    inc counter + 1
.end:
    bit PORTA
    rti

    .org $fffa
    .word nmi
    .word start
    .word irq
