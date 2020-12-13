! Copyright (C) 2019 forthnutter.
!

USING: accessors math math.bitwise make kernel literals byte-arrays binfile ;
IN: parallax.propeller.hub

CONSTANT: ROMSIZE 32768
CONSTANT: RAMSIZE 32768

TUPLE: hub cog bus ram rom enable lock config ;


: <hub> ( -- hub )
  hub new
  "work/parallax/propeller/hub/StartupROM.bin" <binfile> >>rom
  RAMSIZE <byte-array> >>ram ;
