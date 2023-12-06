#importonce

FirePressed: .byte $00

Direction:          // Player sprite direction
  .byte $00         // $00 - no move, $01 - right, $ff - left
DirectionY:         // Player sprite vertical direction
  .byte $00         // $00 - no move, $01 - down, $ff - up

Orientation:        // Player sprite orientation
  .byte $01         // $01 - right, $ff - left

GetJoystickMove: {
    // ldx #$00
    lda c128lib.Cia.CIA1_DATA_PORT_A
    // ldy GameEnded
    // bne CheckOnlyFirePress
    lsr
    bcs !NoUp+
    ldx #$ff

  !NoUp:
    lsr
    bcs !NoDown+
    ldx #$01
  !NoDown:
    stx DirectionY
    ldx #$00
    lsr
    bcs !NoLeft+
    ldx #$ff
    stx Orientation
  !NoLeft:
    lsr
    bcs !NoRight+
    ldx #$01
    stx Orientation
  !NoRight:
    stx Direction
    ldx #$00
    lsr
    bcs !NoFirePressed+
    ldx #$ff
  !NoFirePressed:
    stx FirePressed
    rts

  CheckOnlyFirePress:
    jmp GetOnlyFirePress
}

// Read joystick (port 2) status and set FirePressed to $ff if fire is pressed
// $00 otherwise
GetOnlyFirePress: {
    lda $dc00
    ldx #0
    lsr
    lsr
    lsr
    lsr
    lsr
    bcs !NoFirePressed+
    ldx #$ff
  !NoFirePressed:
    stx FirePressed

    rts
}

#import "./chipset/lib/cia.asm"
