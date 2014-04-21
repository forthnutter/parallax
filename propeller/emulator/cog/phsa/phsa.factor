! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.phsa

TUPLE: phsa < model ;

: <phsa> ( value -- par )
   phsa new-model ;

M: phsa model-changed
   break drop drop ;