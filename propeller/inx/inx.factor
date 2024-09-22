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

! basic read of INX
GENERIC: in-read ( inx -- d )
GENERIC: in-write ( d inx -- )

! Just read the value
M: inx in-read
   model-value ;

! lets write
M: inx in-write
   set-model ;

! a change is applied by external routine
M: inx model-changed
   break
   in-write ;  ! this will change obsevers

! add an observer to the inx
: inx-add-connection ( observer inx -- )
    add-connection ;


! Sets the n th bit of inx to one
: inx-set-bit ( inx n -- )
   [ dup value>> ] dip set-bit
   swap in-write ;

! Sets the n th bit of inx to zero 
: inx-clear-bit ( inx n -- )
   [ dup value>> ] dip clear-bit
   swap in-write ;

! return inx into binary string
: inx>bin ( inx -- str )
   in-read >bin 32 CHAR: 0 pad-head ;

: <inx-bits> ( n -- vb )
    <array>
    [
        <model>
    ] map ;

: <inx> ( value -- inp )
   inx new-model ;


