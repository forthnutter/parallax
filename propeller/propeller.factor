! Copyright (C) 2020 forthnutter.
!

USING: math math.bitwise make kernel literals parallax.propeller.assembler
  compiler.codegen.labels namespaces accessors sequences arrays hashtables
  assocs ;

IN: parallax.propeller

SYMBOL: test

TUPLE: cog memory labels ;

CONSTANT: COG-CELL 4    ! cell size 4 bytes
CONSTANT: COG-SIZE 512  ! cog memory size
CONSTANT: COG-ADDRESS-BITS 9 ! cog addressing limit 9 bits

GENERIC: write ( data address cog -- )
GENERIC: read ( address cog -- data )
GENERIC: label-write ( value key cog --  )
GENERIC: label-address ( key cog -- value )
GENERIC: label-value ( value cog -- key )

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

! add a way to read value from has
M: cog label-address
  labels>> at ;

! get the label from the value
M: cog label-value
  labels>> value-at ;

! add special function register to memory
: cog-sfr ( cod -- cod' )
  [ [ 0x1F0 "PAR" ] dip label-write ] keep ! boot parameter
  [ [ 0x1F1 "CNT" ] dip label-write ] keep ! System counter
  [ [ 0x1F2 "INA" ] dip label-write ] keep ! input states for P31 to P0
  [ [ 0x1F3 "INB" ] dip label-write ] keep ! input states for P63 to P32
  [ [ 0x1F4 "OUTA" ] dip label-write ] keep ! output states for P31 to P0
  [ [ 0x1F5 "OUTB" ] dip label-write ] keep ! output states for P64 to P32
  [ [ 0x1F6 "DIRA" ] dip label-write ] keep ! direction states for P31 to P0
  [ [ 0x1F7 "DIRB" ] dip label-write ] keep ! direction states for P63 to P32
  [ [ 0x1F8 "CTRA" ] dip label-write ] keep ! counter A control
  [ [ 0x1F9 "CTRB" ] dip label-write ] keep ! counter B control
  [ [ 0x1FA "FRQA" ] dip label-write ] keep ! counter A frequency
  [ [ 0x1FB "FRQB" ] dip label-write ] keep ! counter B frequency
  [ [ 0x1FC "PHSA" ] dip label-write ] keep ! counter A phase
  [ [ 0x1FD "PSHB" ] dip label-write ] keep ! counter B phase
  [ [ 0x1FE "VCFG" ] dip label-write ] keep ! Video Configuration
  [ [ 0x1FF "VSCL" ] dip label-write ] keep ! Video Scale
;


! make cog memory
: <cog> ( -- cog )
  cog new
  COG-SIZE f <array> >>memory
  COG-SIZE <hashtable> >>labels
  cog-sfr ! special function 
  ;
