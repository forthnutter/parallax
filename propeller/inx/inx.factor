! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.inx

! inx can be INA and INB 
! and lets combine model object
TUPLE: inx < model ;

! basic read of INX
GENERIC: read ( inx -- d )

! Just read the value
M: inx read
   value>> ;

: inx-read ( inx -- d )
  value>> ;

! we cannot write to this port 
: inx-write ( d inp -- )
   drop drop ;

: <inx> ( value -- inp )
   inx new-model ;


