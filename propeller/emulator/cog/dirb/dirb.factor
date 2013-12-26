! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.dira

TUPLE: dirb < model ;

: <dirb> ( value -- dirb )
   dirb new-model ;

M: dirb model-changed
   break drop drop ;