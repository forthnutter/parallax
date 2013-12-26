! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.dira

TUPLE: dira < model ;

: <dira> ( value -- dira )
   dira new-model ;

M: dira model-changed
   break drop drop ;