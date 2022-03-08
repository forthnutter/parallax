! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel models sequences
   math.bitwise math.parser tools.continuations ;

IN: parallax.propeller.inx

! inx can be INA and INB 
! and lets combine model object
TUPLE: inx < model ;

! basic read of INX
GENERIC: read ( inx -- d )
GENERIC: write ( d inx -- )

! Just read the value
M: inx read
   value>> ;

! lets write
M: inx write
   set-model ;

! a change is applied by external routine
M: inx model-changed
   break
   write ;  ! this will change obsevers

! make sure when activated the value is passed back
! cogs memory all cogs will change at the same time as inx
M: inx model-activated
   break
   [ value>> ] keep write ;

! Sets the n th bit of inx to one
: inx-set-bit ( inx n -- )
   [ dup value>> ] dip set-bit
   swap write ;

! Sets the n th bit of inx to zero 
: inx-clear-bit ( inx n -- )
   [ dup value>> ] dip clear-bit
   swap write ;

! return inx into binary string
: inx>bin ( inx -- str )
   read >bin 32 CHAR: 0 pad-head ;

: <inx> ( value -- inp )
   inx new-model ;


