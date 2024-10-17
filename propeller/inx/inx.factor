! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel models sequences
   math.bitwise math.parser tools.continuations arrays ;

IN: parallax.propeller.inx


CONSTANT: INXNUMBITS  32

! inx can be INA and INB 
! and lets combine model object
TUPLE: inx < model bits ;


! a change is applied by external routine
M: inx model-changed
   break
   [ model-value ] dip
   set-model ;
   
! add an observer to the inx
: inx-add-connection ( observer inx -- )
    add-connection ;

! Sets the n th bit of inx to one
: inx-set-bit ( inx n -- )
   [ dup value>> ] dip set-bit
   swap set-model ;

! Sets the n th bit of inx to zero 
: inx-clear-bit ( inx n -- )
   [ dup value>> ] dip clear-bit
   swap set-model ;

! return inx into binary string
: inx>bin ( inx -- str )
   model-value >bin 32 CHAR: 0 pad-head ;

: <inx-bits> ( n -- vb )
    f <array>
    [
        <model>
    ] map ;


: inx-add-dependency ( dep inx -- )
    add-dependency ;

: <inx> ( value -- inp )
   inx new-model ;


