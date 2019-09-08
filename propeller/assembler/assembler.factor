! Copyright (C) 2019 forthnutter.
!

USING: math.bitwise ;
IN: parallax.propeller.assembler


: insn ( bitspec -- ) bitfield ; inline

: WRBYTE ( ss dd -- )
  {
    { 0 26 }
    { 0 23 }
    22
    { 15 18 }
    9
    0
  } insn
;
