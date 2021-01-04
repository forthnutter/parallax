! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.ctr

TUPLE: ctr < model ;

: <ctr> ( value -- par )
   ctr new-model ;

M: ctr model-changed
   break drop drop ;
