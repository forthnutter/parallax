! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.frqb

TUPLE: frqb < model ;

: <frqb> ( value -- par )
   frqb new-model ;

M: frqb model-changed
   break drop drop ;
