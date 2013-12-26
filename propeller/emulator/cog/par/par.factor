! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.par

TUPLE: par < model ;

: <par> ( value -- par )
   par new-model ;

M: par model-changed
   break drop drop ;