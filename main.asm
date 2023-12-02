
#importonce

.segmentdef Code [start=$1c10]
.segmentdef MapData [start=$4000]

.file [name="./main.prg", segments="Code, MapData", modify="BasicUpstart", _start=$1c10]
.file [name="./EpicEscape.prg", segments="Code, MapData", modify="BasicUpstart", _start=$1c10]
.disk [filename="./EpicEscape.d64", name="EPICESCAPE", id="C2023", showInfo]
{
  [name="----------------", type="rel"],
  [name="--- RAFFAELE ---", type="rel"],
  [name="--- INTORCIA ---", type="rel"],
  [name="----------------", type="rel"],
  [name="EPICESCAPE", type="prg", segments="Code, MapData", modify="BasicUpstart", _start=$1c10],
  [name="----------------", type="rel"]
}

c128lib_BasicUpstart128($1c10)

* = $1c10 "Entry"
Entry: {

    lda #0
    sta $d020
    sta $d021

    jsr 27440

    rts
}

#import "_allimport.asm"
#import "./common/lib/common-global.asm"
