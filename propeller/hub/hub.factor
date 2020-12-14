! Copyright (C) 2019 forthnutter.
!

USING: accessors math math.bitwise make kernel literals byte-arrays binfile
  vectors sequences tools.continuations ;
IN: parallax.propeller.hub

CONSTANT: ROMSIZE 32768
CONSTANT: RAMSIZE 32768
CONSTANT: COGNUMBER 8

TUPLE: hub cog bus ram rom enable lock config ;

! create an instance of 8 cogs
: hub-cog-build ( hub -- hub' )
  break
  COGNUMBER <vector>
  [

  ] with each ;

: <hub> ( -- hub )
  hub new
  "work/parallax/propeller/hub/StartupROM.bin" <binfile> >>rom
  RAMSIZE <byte-array> >>ram
  hub-cog-build ;
