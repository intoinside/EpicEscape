#importonce

// .segment MapData
* = $4000 "IntroMap"
IntroMap:
  // .import binary "./maps/intro.bin"
* = $4400 "Level1"
Level1:
  .import binary "./maps/level1.bin"

* = $7000 "Sprites"
Sprites:
  .import binary "./sprites/sprites.bin"

* = $7800 "Charset"
Charset:
  .import binary "./maps/charset.bin"

* = $c000 "CharColors"
CharColors:
  .import binary "./maps/charcolors.bin"
