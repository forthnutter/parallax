! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.frq

TUPLE: frq < model ;

: <frq> ( value -- par )
   frq new-model ;

M: frq model-changed
   break drop drop ;
