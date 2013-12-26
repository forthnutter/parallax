! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.inb

TUPLE: inb < model ;

: <inb> ( value -- inb )
   inb new-model ;

M: inb model-changed
   break drop drop ;