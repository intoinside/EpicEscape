
#importonce

.macro SetScheduler(handler) {
    lda #<MainScheduler
    sta $0314
    lda #>MainScheduler
    sta $0315

    jmp Quit

  * = * "MainScheduler"
  MainScheduler: {
    lda c128lib.Vic2.IRR
    and #1
    beq Done

    lda Counter
    cmp #60
    bne !+
    lda #255
    sta Counter

  !:
    inc Counter
    bne Done

  Second:
    jsr handler

  Done:
    jmp $fa65

    Counter: .byte 0
  }
  Quit:
}

#import "./chipset/lib/vic2.asm"
