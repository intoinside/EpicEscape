
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

    c128lib_SetBorderAndBackgroundColor(BLACK, BLACK)

    c128lib_SetMMULoadConfiguration(c128lib.Mmu.RAM0 | c128lib.Mmu.IO_ROM | c128lib.Mmu.ROM_LOW_RAM | c128lib.Mmu.ROM_MID_RAM | c128lib.Mmu.ROM_HI_RAM)

    c128lib_SetVICBank(c128lib.Cia.BANK_1)
    c128lib_SetScreenAndCharacterMemory(c128lib.Vic2.CHAR_MEM_3800 | c128lib.Vic2.SCREEN_MEM_0400)

    rts
}

#import "_allimport.asm"
#import "./common/lib/common-global.asm"
#import "./chipset/lib/vic2-global.asm"

#import "_allimport.asm"
