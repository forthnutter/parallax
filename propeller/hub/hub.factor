! Copyright (C) 2019 forthnutter.
!

USING: accessors math math.bitwise make kernel literals byte-arrays binfile
  vectors sequences tools.continuations parallax.propeller.emulator.cog arrays
  intel.hex bit-arrays bit-vectors
 ;
IN: parallax.propeller.hub

CONSTANT: ROMSIZE 32768
CONSTANT: BOOTLOC 0x7800   ! $F800
CONSTANT: RAMSIZE 32768
CONSTANT: COGNUMBER 8

TUPLE: hub cogs cog bus ram rom enable lock config ;

! create an instance of 8 cogs
: hub-cog-array ( -- cog-array )
  COGNUMBER f <array>
  [
    drop drop
    <cog>
  ] map-index ;

! single step cog
: hub-cog-step ( hub -- )
  cogs>> first cog-execute ;

! do the round robin and give access to HUB memory for each cog
: hub-step ( hub -- )
  [ cogs>> pop ] keep >>cog ! get the top cog
  [ cog>> cog-hub ] keep drop drop ;

: hub-cog-boot ( hub -- )
  [ rom>> BOOTLOC tail ] keep
  cogs>> first [ cog-copy ] keep cog-active ;

: hub-bin-hex ( -- bin )
  "work/parallax/propeller/hub/hub_rom_low.hex" <ihex>
  array>>
  "work/parallax/propeller/hub/hub_rom_high.hex" <ihex>
  array>> append
  ;



: <hub> ( -- hub )
  hub new
  "work/parallax/propeller/hub/StartupROM.bin" <binfile> >>rom
  RAMSIZE <byte-array> >>ram
  hub-cog-array >>cogs
  [ hub-cog-boot ] keep
 ;
