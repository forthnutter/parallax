! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models
   vectors tools.continuations ;

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

M: inx write
   set-model ;

! make sure when activated the value is passed back
! cogs memory
M: inx model-activated
   break
   [ value>> ] keep write ;

: <inx> ( value -- inp )
   inx new-model ;


