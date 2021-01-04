! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.cnt

TUPLE: cnt < model ;

: <cnt> ( value -- par )
   cnt new-model ;

M: cnt model-changed
   break drop drop ;
