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

! add two signed values
: ADD ( sv av con zcri -- )
  insn-boundry
  {
    { 0b100000 26 } 22 18 9 0
  } insn ,
;

: ADDABS ( sv av con zcri -- )
  insn-boundry
  {
    { 0b100010 26 } 22 18 9 0
  } insn , ;

: ADDS ( sv av con zcri -- )
  insn-boundry
  { { 0b110100 26 } 22 18 9 0 } insn , ;

: ADDSX ( sv av con zcri -- )
  insn-boundry
  { { 0b110110 26 } 22 18 9 0 } insn , ;

! Bitwise AND two values
: AND ( sv av con zcri -- )
  insn-boundry
  { { 0b011000 26 } 22 18 9 0 } insn , ;

! Bitwise AND a value with the NOT of another.
: ANDN ( sv av con zcri -- )
  insn-boundry
  { { 0b011001 26 } 22 18 9 0 } insn , ;

! Jump to address with intention to return to next instruction.
: CALL ( sv av con zcri -- )
  insn-boundry
  { { 0b010111 26 } 22 18 9 0 } insn , ;


! Set the clock mode at run time.
: CLKSET ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Compare two unsigned values
: CMP ( sv av con zcri -- )
  insn-boundry
  { { 0b100001 26 } 22 18 9 0 } insn , ;

! Compare two signed values.
: CMPS ( sv av con zcri -- )
  insn-boundry
  { { 0b110000 26 } 22 18 9 0 } insn , ;

! Compare two unsigned values and subtract the second if it is lesser or equal.
: CMPSUB ( sv av con zcri -- )
  insn-boundry
  { { 0b111000 26 } 22 18 9 0 } insn , ;

! Compare two signed values plus C.
: CMPSX ( sv av con zcri -- )
  insn-boundry
  { { 0b110001 26 } 22 18 9 0 } insn , ;

! Compare two unsigned values plus C
: CMPX ( sv av con zcri -- )
  insn-boundry
  { { 0b110011 26 } 22 18 9 0 } insn , ;

! Get current cog’s ID.
: COGID ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Start or restart a cog, optionally by ID, to run Propeller Assembly or Spin code.
: COGINIT ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Stop  a cog by its ID.
: COGSTOP ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Decrement value and jump to address if not zero.
: DJNZ ( sv av con zcri -- )
  insn-boundry
  { { 0b111001 26 } 22 18 9 0 } insn , ;

! Perform a hub operation.
: HUBOP ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Jump to address.
: JMP ( sv av con zcri -- )
  insn-boundry
  { { 0b010111 26 } 22 18 9 0 } insn , ;

! Jump to address with intention to “return” to another address.
: JMPRET ( sv av con zcri -- )
  insn-boundry
  { { 0b010111 26 } 22 18 9 0 } insn , ;

! Clear lock to false and get its previous state.
: LOCKCLR ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Check out a new lock and get its ID.
: LOCKNEW ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Release lock back for future “new lock” requests.
: LOCKRET ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Set lock to true and get its previous state.
: LOCKSET ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;


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
