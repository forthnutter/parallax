! Copyright (C) 2019 forthnutter.
!

USING: math.bitwise make kernel ;
IN: parallax.propeller.assembler

: <#> ( -- b )
  0b0001 ;

: WZ ( -- b )
  0b1000 ;

: WC ( -- b )
  0b0100 ;

: WR ( -- b )
  0b0010 ;

: insn ( bitspec -- ) bitfield ; inline

! make sure that the parameters are with boundries
: insn-boundry ( ss dd con zcri -- ss dd con zcri )
  4 bits [ 4 bits ] dip [ 9 bits ] 2dip [ 9 bits ] 3dip ;


! ABS takes the absolute value of SValue and writes the result into AValue.
: ABS ( sv av con zcri -- )
  insn-boundry
  {
    { 0b101010 26 } 22 18 9 0
  } insn ,
;

! Get the negative of a number’s absolute value.
: ABSNEG ( sv av con zcri -- )
  insn-boundry
  {
    { 0b101011 26 } 22 18 9 0
  } insn , ;


! WRBYTE synchronizes to the Hub and writes the lowest byte
! in Value to main memory at Address.
: WRBYTE ( ss dd con zcri -- )
  insn-boundry
  {
    { 0 26 } 22 18 9 0
  } insn ,
;

! WRLONG synchronizes to the Hub and writes the long in Value
! to main memory at Address.
: WRLONG ( ss dd con zcri -- )
  insn-boundry
  {
    { 0b000010 26 } 22 18 9 0
  } insn ,
;
