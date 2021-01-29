! Copyright (C) 2019 forthnutter.
!

USING: accessors math math.bitwise make kernel literals byte-arrays binfile
  vectors sequences tools.continuations parallax.propeller.cogs arrays
  intel.hex bit-arrays bit-vectors io
 ;
IN: parallax.propeller.hub

CONSTANT: ROMSIZE 32768
CONSTANT: BOOTLOC 0x7800   ! $F800
CONSTANT: RAMSIZE 32768


TUPLE: hub cogs bus ram rom enable lock config ;



! sigle cycle cog
: hub-cog-step ( hub -- hub )
  [ cogs>> cogs-step-cycle ] keep ;

! single step cog
: hub-cog-clock ( hub -- hub )
  [ cogs>> cogs-step-clock ] keep ;

! do the round robin and give access to HUB memory for each cog
: hub-clock-step ( hub -- )
  drop ;

: hub-cog-boot ( hub -- )
  [ rom>> BOOTLOC tail ] keep
  cogs>> cogs-boot ;

: hub-bin-hex ( -- bin )
  "work/parallax/propeller/hub/hub_rom_low.hex" <ihex>
  array>>
  "work/parallax/propeller/hub/hub_rom_high.hex" <ihex>
  array>> append ;

! display cog memory
: hub-cog-mdl ( cogn address hub -- hub )
  [
    cogs>> [ 8 ] 3dip cogs-mdl
    [ print ] each
  ] keep ;

! display cog disasembley
: hub-cog-list ( cogn address hub -- hub )
  [
    cogs>> [ 4 ] 3dip cogs-list
    [ print ] each
  ] keep ;

: <hub> ( -- hub )
  hub new
  "work/parallax/propeller/hub/StartupROM.bin" <binfile> >>rom
  RAMSIZE <byte-array> >>ram
  <cogs> >>cogs ! cogs is seperate class
  [ hub-cog-boot ] keep
 ;
