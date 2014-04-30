! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.vscl

TUPLE: vscl < model ;

: <vscl> ( value -- par )
   vscl new-model ;

M: vscl model-changed
   break drop drop ;