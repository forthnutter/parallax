! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.in

TUPLE: in < model ;

GENERIC: read ( ina -- d )

M: in read
  value>> ;

: <in> ( value -- ina )
   in new-model ;

M: in model-changed
   break drop drop ;
