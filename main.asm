
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
  [name="EPIC-ESCAPE", type="prg", segments="Code, MapData", modify="BasicUpstart", _start=$1c10],
  [name="----------------", type="rel"]
}

c128lib_BasicUpstart128($1c10)

* = $1c10 "Entry"
Entry: {
    c128lib_SetBorderAndBackgroundColor(BLACK, DARK_GREY)
    c128lib_SetBackgroundForegroundColor(c128lib.Vdc.VDC_DARK_BLUE, c128lib.Vdc.VDC_LIGHT_BLUE)

    // c128lib_FillScreen(32)

    // c128lib_WriteToVdcMemoryByCoordinates(source, 5, 5, 11)

    // c128lib_SetScreenAndCharacterMemory(c128lib.Vic2.CHAR_MEM_3800 | c128lib.Vic2.SCREEN_MEM_0400)

    lda #$ff
    sta c128lib.Vic2.SCREEN_EDITOR_IRQ_FLAG

    // Vic and Cpu see bank 0, Vic sees ram instead of rom
    lda $01
    and #%11111000
    ora #%00000100
    sta $01

    c128lib_SetMMULoadConfiguration(c128lib.Mmu.RAM0 | c128lib.Mmu.IO_ROM | c128lib.Mmu.ROM_LOW_RAM | c128lib.Mmu.ROM_MID_RAM | c128lib.Mmu.ROM_HI_RAM)

    c128lib_SetVICBank(c128lib.Cia.BANK_1)

    // Setup charmem/charpos
    // c128lib_SetScreenAndCharacterMemory(c128lib.Vic2.CHAR_MEM_3800 | c128lib.Vic2.SCREEN_MEM_0400)
    // sta $d016

    // Set multicolor mode
    lda c128lib.Vic2.CONTROL_2
    ora #c128lib.Vic2.CONTROL_2_MCM
    sta c128lib.Vic2.CONTROL_2

    lda #DARK_GRAY
    sta c128lib.Vic2.BG_COL_0
    lda #ORANGE
    sta c128lib.Vic2.BG_COL_1
    lda #LIGHT_RED
    sta c128lib.Vic2.BG_COL_2

    SetColorForMap(Level1)

    // Sprite multicolor mode
    lda #%00000010
    sta c128lib.Vic2.SPRITE_COL_MODE

    lda #WHITE
    sta c128lib.Vic2.SPRITE_0_COLOR
    lda #BLACK
    sta c128lib.Vic2.SPRITE_1_COLOR

    lda #LIGHT_RED
    sta c128lib.Vic2.SPRITE_COL_0
    lda #LIGHT_GREY
    sta c128lib.Vic2.SPRITE_COL_1

    lda #PlayerStartingX
    sta c128lib.Vic2.SHADOW_SPRITE_0_X
    sta c128lib.Vic2.SHADOW_SPRITE_1_X
    lda #PlayerStartingY
    sta c128lib.Vic2.SHADOW_SPRITE_0_Y
    sta c128lib.Vic2.SHADOW_SPRITE_1_Y

    lda #SPRITES.PLAYER_STAND_L0
    sta SPRITES.SPRITES_0
    lda #SPRITES.PLAYER_STAND_L1_RIGHT
    sta SPRITES.SPRITES_1

    lda #%11
    sta c128lib.Vic2.SPRITE_ENABLE

  Loop:
    jsr WaitRoutine
    // If player is moving, keep joystick movement
    lda IsMoving
    bne !+

    // If player is not moving, get new joystick movement
    jsr GetJoystickMove
  !:
    HandlePlayerMovement(IsMoving)

    jmp Loop

    rts

    IsMoving: .byte 0
}

.label PlayerLimitLeftX = 31
.label PlayerLimitRightX = 254
.label PlayerLimitUpY = 55
.label PlayerLimitDownY = 230

.label PlayerStartingX = 62
.label PlayerStartingY = 54

.macro HandlePlayerMovement(IsMoving) {
    lda Direction
    cmp #$1
    beq MoveRight
    cmp #$ff
    beq MoveLeft
    jmp CheckVerticalMove

  LoopFar:
    jmp Loop

  MoveRight:
    lda c128lib.Vic2.SHADOW_SPRITE_0_X
    cmp #PlayerLimitRightX
    bcs LoopFar
    lda IsMoving
    bne !+
    // Player should move right, but it's still, setup new IsMoving
    lda #MoveOffset + 1
    sta IsMoving
    ldx #SPRITES.PLAYER_WALKDOWN_STEP1_L0
    stx SPRITES.SPRITES_0
    ldx #SPRITES.PLAYER_WALKDOWN_STEP1_L1_RIGHT
    stx SPRITES.SPRITES_1

  !:
    lsr
    bcc !Move+

    cpx #SPRITES.PLAYER_WALKDOWN_STEP1_L1_RIGHT
    beq !Switch+
    lda #SPRITES.PLAYER_WALKDOWN_STEP1_L0
    ldx #SPRITES.PLAYER_WALKDOWN_STEP1_L1_RIGHT
    jmp !+
  !Switch:
    lda #SPRITES.PLAYER_WALKDOWN_STEP2_L0
    ldx #SPRITES.PLAYER_WALKDOWN_STEP2_L1_RIGHT
  !:
    sta SPRITES.SPRITES_0
    stx SPRITES.SPRITES_1
  !Move:
    dec IsMoving
    bne !+

  !:
    inc c128lib.Vic2.SHADOW_SPRITE_0_X
    inc c128lib.Vic2.SHADOW_SPRITE_1_X
    jmp CheckVerticalMove

  MoveLeft:
    lda c128lib.Vic2.SHADOW_SPRITE_0_X
    cmp #PlayerLimitLeftX
    bcc LoopFar
    lda IsMoving
    bne !+
    // Player should move left, but it's still, setup new IsMoving
    lda #MoveOffset + 1
    sta IsMoving
    ldx #SPRITES.PLAYER_WALKDOWN_STEP1_L0
    stx SPRITES.SPRITES_0
    ldx #SPRITES.PLAYER_WALKDOWN_STEP1_L1_LEFT
    stx SPRITES.SPRITES_1

  !:
    lsr
    bcc !Move+

    cpx #SPRITES.PLAYER_WALKDOWN_STEP1_L1_LEFT
    beq !Switch+
    lda #SPRITES.PLAYER_WALKDOWN_STEP1_L0
    ldx #SPRITES.PLAYER_WALKDOWN_STEP1_L1_LEFT
    jmp !+
  !Switch:
    lda #SPRITES.PLAYER_WALKDOWN_STEP2_L0
    ldx #SPRITES.PLAYER_WALKDOWN_STEP2_L1_LEFT
  !:
    sta SPRITES.SPRITES_0
    stx SPRITES.SPRITES_1
  !Move:
    dec IsMoving

    dec c128lib.Vic2.SHADOW_SPRITE_0_X
    dec c128lib.Vic2.SHADOW_SPRITE_1_X

  CheckVerticalMove:
    lda DirectionY
    cmp #$1
    beq MoveDown
    cmp #$ff
    beq MoveUp
    jmp NoMove

  MoveDown:
    lda c128lib.Vic2.SHADOW_SPRITE_0_Y
    cmp #PlayerLimitDownY
    bcs Loop
    lda IsMoving
    bne !+
    // Player should move down, but it's still, setup new IsMoving
    lda #MoveOffset
    sta IsMoving
  !:
    dec IsMoving
    inc c128lib.Vic2.SHADOW_SPRITE_0_Y
    inc c128lib.Vic2.SHADOW_SPRITE_1_Y
    jmp Loop

  MoveUp:
    lda c128lib.Vic2.SHADOW_SPRITE_0_Y
    cmp #PlayerLimitUpY
    bcc Loop
    lda IsMoving
    bne !+
    // Player should move up, but it's still, setup new IsMoving
    lda #MoveOffset
    sta IsMoving
  !:
    dec IsMoving
    dec c128lib.Vic2.SHADOW_SPRITE_0_Y
    dec c128lib.Vic2.SHADOW_SPRITE_1_Y
    jmp Loop

  NoMove:
    lda Orientation
    cmp #1
    beq RightOrientation
    cmp #$ff
    beq LeftOrientation
    jmp Loop
  RightOrientation:
    lda #SPRITES.PLAYER_STAND_L0
    sta SPRITES.SPRITES_0
    lda #SPRITES.PLAYER_STAND_L1_RIGHT
    sta SPRITES.SPRITES_1
    jmp Loop

  LeftOrientation:
    lda #SPRITES.PLAYER_STAND_L0
    sta SPRITES.SPRITES_0
    lda #SPRITES.PLAYER_STAND_L1_LEFT
    sta SPRITES.SPRITES_1
    jmp Loop

  Loop:

    .label MoveOffset = 4
}

WaitRoutine: {
  VBLANKWAITLOW:
    lda c128lib.Vic2.CONTROL_1
    bpl VBLANKWAITLOW
  VBLANKWAITHIGH:
    lda c128lib.Vic2.CONTROL_1
    bmi VBLANKWAITHIGH
    rts
}

source: .text "epic escape"

#define VDC_FILLSCREEN
#import "./common/lib/common-global.asm"
#import "./chipset/lib/mmu-global.asm"
#import "./chipset/lib/cia-global.asm"
#import "./chipset/lib/vic2-global.asm"
#import "./chipset/lib/vdc-global.asm"

#import "_sprites.asm"
#import "_utils.asm"
#import "_joystick.asm"
#import "_allimport.asm"
