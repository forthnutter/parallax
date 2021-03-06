! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.phsb

TUPLE: phsb < model ;

: <phsb> ( value -- par )
   phsb new-model ;

M: phsb model-changed
   break drop drop ;
