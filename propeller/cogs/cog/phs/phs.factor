! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.phs

TUPLE: phs < model ;

: <phs> ( value -- par )
   phs new-model ;

M: phs model-changed
   break drop drop ;
