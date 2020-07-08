! Copyright (C) 2019 forthnutter.
!

USING: math math.bitwise make kernel literals parallax.propeller.assembler
  namespaces arrays accessors parser words words.symbol words.constant
  sequences tools.continuations compiler.codegen.labels hashtables
  assocs ;


IN: parallax.propeller.assembler.cog

TUPLE: cog ip dp memory labels ;

CONSTANT: COG-CELL 4    ! cell size 4 bytes
CONSTANT: COG-SIZE 512  ! cog memory size
CONSTANT: COG-ADDRESS-BITS 9 ! cog addressing limit 9 bits

GENERIC: write ( data address cog -- )
GENERIC: read ( address cog -- data )
GENERIC: label-write ( value key cog --  )
GENERIC: label-address ( key cog -- value )
GENERIC: label-value ( value cog -- key )


<<

SYMBOL: registers

H{ } registers set-global

SYNTAX: REGISTER:
    scan-new-word scan-object [ define-constant ] 2keep
    [ drop registers get assoc-size "register" set-word-prop ] 2keep
    registers get set-at ;

>>


! Register Special Function Register
REGISTER: PAR  0x1F0  ! boot parameter
REGISTER: CNT  0x1F1  ! System counter
REGISTER: INA  0x1F2  ! input states for P31 to P0
REGISTER: INB  0x1F3  ! input states for P63 to P32
REGISTER: OUTA 0x1F4  ! output states for P31 to P0
REGISTER: OUTB 0x1F5  ! output states for P64 to P32
REGISTER: DIRA 0x1F6  ! direction states for P31 to P0
REGISTER: DIRB 0x1F7  ! direction states for P63 to P32
REGISTER: CTRA 0x1F8  ! counter A control
REGISTER: CTRB 0x1F9  ! counter B control
REGISTER: FRQA 0x1FA  ! counter A frequency
REGISTER: FRQB 0x1FB  ! counter B frequency
REGISTER: PHSA 0x1FC  ! counter A phase
REGISTER: PHSB 0x1FD  ! counter B phase
REGISTER: VCFG 0x1FE  ! Video Configuration
REGISTER: VSCL 0x1FF  ! Video Scale

! need something to write to cog memory
M: cog write
  [ COG-ADDRESS-BITS bits ] dip      ! make sure we limit address to 9 bits
  memory>> ?set-nth ;

! need some code to read from cog memory
M: cog read
  [ COG-ADDRESS-BITS bits ] dip      ! yes we can only work with 9 bits
  memory>> ?nth ;

! add lable and address to lable hash
M: cog label-write
  labels>> set-at ;

! add a way to read value from hash key
M: cog label-address
  labels>> at ;

! get the label from the value
M: cog label-value
  labels>> value-at ;


! make cog memory
: <cog> ( -- cog )
  cog new
  0 >>ip      ! instruction pointer
  0x1E0 >>dp  ! data pointer
  COG-SIZE f <array> >>memory ; ! cog memory
