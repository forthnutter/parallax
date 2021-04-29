! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.inp

TUPLE: inp < model ;


: inp-read ( inp -- d )
  value>> ;

! we cannot write to this port 
: inp-write ( d inp -- )
   drop drop ;

: <inp> ( value -- inp )
   inp new-model ;


