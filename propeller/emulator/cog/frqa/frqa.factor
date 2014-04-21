! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.frqa

TUPLE: frqa < model ;

: <frqa> ( value -- par )
   frqa new-model ;

M: frqa model-changed
   break drop drop ;