! Copyright (C) 2019 forthnutter.
!

USING: math math.bitwise make kernel literals ;
IN: parallax.propeller.assembler


! effects
CONSTANT: <#> 0b0001 ! literal indicator
CONSTANT: WR 0b0010 ! updates destination
CONSTANT: WC 0b0100 ! update C flag
CONSTANT: WZ 0b1000 ! update Z flag

! condition
CONSTANT: IF_NEVER     0b0000  ! like nop instruction
CONSTANT: IF_A         0b0001  ! if above (!c & !z = 1)
CONSTANT: IF_NC_AND_NZ 0b0001
CONSTANT: IF_NZ_AND_NC 0b0001
CONSTANT: IF_NC_AND_Z  0b0010 ! if c clear and z Set
CONSTANT: IF_Z_AND_NC  0b0010
CONSTANT: IF_NC        0b0011 ! if c clear
CONSTANT: IF_AE        0b0011 ! if above or equal
CONSTANT: IF_C_AND_NZ  0b0100 ! if c set and z clear
CONSTANT: IF_NZ_AND_C  0b0100
CONSTANT: IF_NE        0b0101 ! if not equal
CONSTANT: IF_NZ        0b0101 ! if not zero
CONSTANT: IF_C_NE_Z    0b0110 ! if c not equal to z
CONSTANT: IF_Z_NE_C    0b0110 ! if z not equal to c
CONSTANT: IF_NC_OR_NZ  0b0111 ! if C or Z
CONSTANT: IF_NZ_OR_NC  0b0111 ! if Z or c
CONSTANT: IF_C_AND_Z   0b1000 ! if c and z
CONSTANT: IF_Z_AND_C   0b1000 ! if z and c
CONSTANT: IF_C_EQ_Z    0b1001 ! if c equal z
CONSTANT: IF_Z_EQ_C    0b1001 ! if z equal c
CONSTANT: IF_E         0b1010 ! if equal
CONSTANT: IF_Z         0b1010 ! if zero
CONSTANT: IF_NC_OR_Z   0b1011 ! if not c or Z
CONSTANT: IF_Z_OR_NZ   0b1011 ! Z = 1 or C = 0
CONSTANT: IF_B         0b1100 ! if below
CONSTANT: IF_C         0b1100 ! c= 1
CONSTANT: IF_C_OR_NZ   0b1101 ! c = 1 or z = 0
CONSTANT: IF_NZ_OR_C   0b1101 !
CONSTANT: IF_C_OR_Z    0b1110 ! c=1 or z = 1
CONSTANT: IF_BE        0b1110 ! if below or equal
CONSTANT: IF_Z_OR_C    0b1110
CONSTANT: IF_ALWAYS    0b1111    ! default condition


! Cog RAM Special Purpose Registers
CONSTANT: PAR 0x1F0 ! boot parameter
CONSTANT: CNT 0x1F1 ! System counter
CONSTANT: INA 0x1F2 ! input states for P31 to P0
CONSTANT: INB 0x1F3 ! input states for P63 to P32
CONSTANT: OUTA 0x1F4 ! output states for P31 to P0
CONSTANT: OUTB 0x1F5 ! output states for P64 to P32
CONSTANT: DIRA 0x1F6 ! direction states for P31 to P0
CONSTANT: DIRB 0x1F7 ! direction states for P63 to P32
CONSTANT: CTRA 0x1F8 ! counter A control
CONSTANT: CTRB 0x1F9 ! counter B control
CONSTANT: FRQA 0x1FA ! counter A frequency
CONSTANT: FRQB 0x1FB ! counter B frequency
CONSTANT: PHSA 0x1FC ! counter A phase
CONSTANT: PHSB 0x1FD ! counter B phase
CONSTANT: VCFG 0x1FE ! Video Configuration
CONSTANT: VSCL 0x1FF ! Video Scale

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

! Perform a hub operation.
: HUBOP ( sv av con zcri -- )
  insn-boundry
  { { 0b000011 26 } 22 18 9 0 } insn , ;

! Set the clock mode at run time.
: CLKSET ( av con zcri -- )
  flags{ <#> } bitor  ! make sure i bit is set
  [ 0 ] 3dip          ! source is 0 for clkset
  HUBOP ;             ! now pass every thing to the HUBOP

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
: COGID ( d con zcri -- )
  flags{ <#> } bitor  ! make sure i bit is set
  [ 1 ] 3dip          ! source is 1 for cogid
  HUBOP ;             ! now pass every thing to the HUBOP

! Start or restart a cog, optionally by ID, to run Propeller Assembly or Spin code.
: COGINIT ( d con zcri -- )
  flags{ <#> } bitor  ! make sure i bit is set
  [ 2 ] 3dip          ! source is 2 for coginit
  HUBOP ;             ! now pass every thing to the HUBOP

! Stop  a cog by its ID.
: COGSTOP ( d con zcri -- )
  flags{ <#> } bitor  ! make sure i bit is set
  [ 3 ] 3dip          ! source is 3 for cogstop
  HUBOP ;             ! now pass every thing to the HUBOP

! Decrement value and jump to address if not zero.
: DJNZ ( sv av con zcri -- )
  insn-boundry
  { { 0b111001 26 } 22 18 9 0 } insn , ;

! Jump to address.
: JMP ( sv av con zcri -- )
  insn-boundry
  { { 0b010111 26 } 22 18 9 0 } insn , ;

! Jump to address with intention to “return” to another address.
: JMPRET ( sv av con zcri -- )
  insn-boundry
  { { 0b010111 26 } 22 18 9 0 } insn , ;

! Clear lock to false and get its previous state.
: LOCKCLR ( d con zcri -- )
  flags{ <#> } bitor  ! make sure i bit is set
  [ 7 ] 3dip          ! source is 7 for lockclr
  HUBOP ;             ! now pass every thing to the HUBOP

! Check out a new lock and get its ID.
: LOCKNEW ( d con zcri -- )
  flags{ <#> } bitor  ! make sure i bit is set
  [ 4 ] 3dip          ! source is 4 for locknew
  HUBOP ;             ! now pass every thing to the HUBOP

! Release lock back for future “new lock” requests.
: LOCKRET ( d con zcri -- )
  flags{ <#> } bitor  ! make sure i bit is set
  [ 5 ] 3dip          ! source is 5 for lockret
  HUBOP ;             ! now pass every thing to the HUBOP

! Set lock to true and get its previous state.
: LOCKSET ( d con zcri -- )
  flags{ <#> } bitor  ! make sure i bit is set
  [ 6 ] 3dip          ! source is 6 for lockset
  HUBOP ;             ! now pass every thing to the HUBOP

! Limit maximum of unsigned value to another unsigned value.
: MAX ( sv av con zcri -- )
  insn-boundry
  { { 0b010011 26 } 22 18 9 0 } insn , ;

! Limit maximum of signed value to another signed value.
: MAXS ( sv av con zcri -- )
  insn-boundry
  { { 0b010001 26 } 22 18 9 0 } insn , ;

! Limit minimum of unsigned value to another unsigned value.
: MIN ( sv av con zcri -- )
  insn-boundry
  { { 0b010010 26 } 22 18 9 0 } insn , ;

! Limit minimum of signed value to another signed value.
: MINS ( sv av con zcri -- )
  insn-boundry
  { { 0b010000 26 } 22 18 9 0 } insn , ;

! Set a register to a value.
: MOV ( src dest con zcri -- )
  insn-boundry
  { { 0b101000 26 } 22 18 9 0 } insn , ;

! Set a register’s destination field to a value.
: MOVD ( sv av con zcri -- )
  insn-boundry
  { { 0b010101 26 } 22 18 9 0 } insn , ;

! Set a register’s instruction and effects fields to a value.
: MOVI ( sv av con zcri -- )
  insn-boundry
  { { 0b010110 26 } 22 18 9 0 } insn , ;

! Set a register’s source field to a value.
: MOVS ( sv av con zcri -- )
  insn-boundry
  { { 0b010100 26 } 22 18 9 0 } insn , ;

! Set discrete bits of a value to the state of C
: MUXC ( sv av con zcri -- )
  insn-boundry
  { { 0b011100 26 } 22 18 9 0 } insn , ;

! Set discrete bits of a value to the state of !C.
: MUXNC ( sv av con zcri -- )
  insn-boundry
  { { 0b011101 26 } 22 18 9 0 } insn , ;

! Set discrete bits of a value to the state of !Z.
: MUXNZ ( sv av con zcri -- )
  insn-boundry
  { { 0b011111 26 } 22 18 9 0 } insn , ;

! Set discrete bits of a value to the state of Z.
: MUXZ ( sv av con zcri -- )
  insn-boundry
  { { 0b011110 26 } 22 18 9 0 } insn , ;

! Get the negative of a number.
: NEG ( sv av con zcri -- )
  insn-boundry
  { { 0b101001 26 } 22 18 9 0 } insn , ;

! Get a value, or its additive inverse, based on C
: NEGC ( sv av con zcri -- )
  insn-boundry
  { { 0b101100 26 } 22 18 9 0 } insn , ;

! Get a value, or its additive inverse, based on !C.
: NEGNC ( sv av con zcri -- )
  insn-boundry
  { { 0b101101 26 } 22 18 9 0 } insn , ;

! Get a value, or its additive inverse, based on !Z.
: NEGNZ ( sv av con zcri -- )
  insn-boundry
  { { 0b101111 26 } 22 18 9 0 } insn , ;

! Get a value, or its additive inverse, based on Z.
: NEGZ ( sv av con zcri -- )
  insn-boundry
  { { 0b101110 26 } 22 18 9 0 } insn , ;


! No operation, just elapse four clock cycles.
: NOP ( sv av zcri instr -- )
  insn-boundry
  { 26 22 { 0 18 } 9 0 } insn , ;

! Bitwise OR two values.
: OR ( sv av con zcri -- )
  insn-boundry
  { { 0b011010 26 } 22 18 9 0 } insn , ;

! Rotate C left into value by specified number of bits.
: RCL ( sv av con zcri -- )
  insn-boundry
  { { 0b001101 26 } 22 18 9 0 } insn , ;

! Rotate C right into value by specified number of bits.
: RCR ( sv av con zcri -- )
  insn-boundry
  { { 0b001100 26 } 22 18 9 0 } insn , ;

! Read byte of main memory.
: RDBYTE ( ss dd con zcri -- )
  insn-boundry
  { { 0 26 } 22 18 9 0 } insn , ;

! Read long of main memory.
: RDLONG ( ss dd con zcri -- )
  insn-boundry
  { { 0b000010 26 } 22 18 9 0 } insn , ;

! Read word of main memory.
: RDWORD ( ss dd con zcri -- )
  insn-boundry
  { { 0b000001 26 } 22 18 9 0 } insn , ;

! Return to previously recorded address.
: RET ( ss dd con zcri -- )
  insn-boundry
  { { 0b010111 26 } 22 18 9 0 } insn , ;

! Reverse LSBs of value and zero-extend.
: REV ( ss dd con zcri -- )
  insn-boundry
  { { 0b001111 26 } 22 18 9 0 } insn , ;

! Rotate value left by specified number of bits.
: ROL ( ss dd con zcri -- )
  insn-boundry
  { { 0b001001 26 } 22 18 9 0 } insn , ;

! Rotate value right by specified number of bits.
: ROR ( ss dd con zcri -- )
  insn-boundry
  { { 0b001000 26 } 22 18 9 0 } insn , ;

! Shift value arithmetically right by specified number of bits.
: SAR ( ss dd con zcri -- )
  insn-boundry
  { { 0b001110 26 } 22 18 9 0 } insn , ;

! Shift value left by specified number of bits.
: SHL ( ss dd con zcri -- )
  insn-boundry
  { { 0b001011 26 } 22 18 9 0 } insn , ;

! Shift value right by specified number of bits.
: SHR ( ss dd con zcri -- )
  insn-boundry
  { { 0b001010 26 } 22 18 9 0 } insn , ;

! Subtract two unsigned values.
: SUB ( ss dd con zcri -- )
  insn-boundry
  { { 0b100001 26 } 22 18 9 0 } insn , ;

! Subtract an absolute value from another value.
: SUBABS ( ss dd con zcri -- )
  insn-boundry
  { { 0b100011 26 } 22 18 9 0 } insn , ;

! Subtract two signed values.
: SUBS ( ss dd con zcri -- )
  insn-boundry
  { { 0b110101 26 } 22 18 9 0 } insn , ;

! Subtract signed value plus C from another signed value.
: SUBSX ( ss dd con zcri -- )
  insn-boundry
  { { 0b110111 26 } 22 18 9 0 } insn , ;

! Subtract unsigned value plus C from another unsigned value.
: SUBX ( ss dd con zcri -- )
  insn-boundry
  { { 0b110011 26 } 22 18 9 0 } insn , ;

! Sum a signed value with another whose sign is inverted depending on C.
: SUMC ( ss dd CON zcri -- )
  insn-boundry
  { { 0b100100 26 } 22 18 9 0 } insn , ;

! Sum a signed value with another whose sign is inverted depending on !C.
: SUMNC ( ss dd con zcri -- )
  insn-boundry
  { { 0b100101 26 } 22 18 9 0 } insn , ;

! Sum a signed value with another whose sign is inverted depending on !Z.
: SUMNZ ( ss dd con zcri -- )
  insn-boundry
  { { 0b100111 26 } 22 18 9 0 } insn , ;

! Sum a signed value with another whose sign is inverted depending on Z.
: SUMZ ( ss dd con zcri -- )
  insn-boundry
  { { 0b100110 26 } 22 18 9 0 } insn , ;

! Bitwise AND two values to affect flags only.
: TEST ( ss dd con zcri -- )
  insn-boundry
  { { 0b011000 26 } 22 18 9 0 } insn , ;

! Bitwise AND a value with the NOT of another to affect flags only.
: TESTN ( ss dd con zcri -- )
  insn-boundry
  { { 0b011001 26 } 22 18 9 0 } insn , ;

! Test value and jump to address if not zero.
: TJNZ ( ss dd con zcri -- )
  insn-boundry
  { { 0b111010 26 } 22 18 9 0 } insn , ;

! Test value and jump to address if zero.
: TJZ ( ss dd con zcri -- )
  insn-boundry
  { { 0b111011 26 } 22 18 9 0 } insn , ;

! Pause a cog’s execution temporarily.
: WAITCNT ( ss dd con zcri -- )
  insn-boundry
  { { 0b111110 26 } 22 18 9 0 } insn , ;

! Pause a cog’s execution until I/O pin(s) match designated state(s).
: WAITPEQ ( ss dd con zcri -- )
  insn-boundry
  { { 0b111100 26 } 22 18 9 0 } insn , ;

! Pause a cog’s execution until I/O pin(s) do not match designated state(s).
: WAITPNE ( ss dd con zcri -- )
  insn-boundry
  { { 0b111101 26 } 22 18 9 0 } insn , ;

! Pause a cog’s execution until its Video Generator is available to take pixel data.
: WAITVID ( ss dd con zcri -- )
  insn-boundry
  { { 0b111111 26 } 22 18 9 0 } insn , ;

! WRBYTE synchronizes to the Hub and writes the lowest byte
! in Value to main memory at Address.
: WRBYTE ( ss dd con zcri -- )
  insn-boundry
  { { 0b000000 26 } 22 18 9 0 } insn , ;

! WRLONG synchronizes to the Hub and writes the long in Value
! to main memory at Address.
: WRLONG ( ss dd con zcri -- )
  insn-boundry
  { { 0b000010 26 } 22 18 9 0 } insn , ;

! Write a word to main memory.
: WRWORD ( ss dd con zcri -- )
  insn-boundry
  { { 0b000001 26 } 22 18 9 0 } insn , ;

! Bitwise XOR two values.
: XOR ( ss dd con zcri -- )
  insn-boundry
  { { 0b011011 26 } 22 18 9 0 } insn , ;
