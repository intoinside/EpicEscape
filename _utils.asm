
#importonce

.macro SetColorForMap(address) {
    ldx #0
  PaintCols:
    .for (var offset = 0; offset <= 3; offset++) {
      ldy address + ($100 * offset), x
      lda CharColors, y
      sta c128lib.Vic2.COLOR_RAM + ($100 * offset), x
    }
    dex
    bne PaintCols
}

#import "_allimport.asm"

#import "./chipset/lib/vic2.asm"
