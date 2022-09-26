! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel models sequences
   math.bitwise math.parser tools.continuations ;

IN: parallax.propeller.ddrx

! DDRx can be DDRA and DDRB 
! DDR is the data direction register
TUPLE: ddrx < model ;

! basic read of DDRx
GENERIC: ddr-read ( ddrx -- d )
GENERIC: ddr-write ( d ddrx -- )

! Just read the value
M: ddrx ddr-read
   value>> ;

! lets write
M: ddrx ddr-write
   set-model ;

! a change is applied by external routine
M: ddrx model-changed
   [ value>> ] dip
   ddr-write ;  ! this will change obsevers


! Sets the n th bit of DDR to one
: ddrx-set-bit ( ddrx n -- )
   [ dup value>> ] dip set-bit
   swap ddr-write ;

! Sets the n th bit of inx to zero 
: ddrx-clear-bit ( ddrx n -- )
   [ dup value>> ] dip clear-bit
   swap ddr-write ;

! return DDR into binary string
: ddrx>bin ( ddrx -- str )
   ddr-read >bin 32 CHAR: 0 pad-head ;

: ddrx-dependency ( dep ddrx -- )
    add-dependency ;


: <ddrx> ( value -- inp )
   ddrx new-model ;

