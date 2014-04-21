! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.vcfg

TUPLE: vcfg < model ;

: <vcfg> ( value -- par )
   vcfg new-model ;

M: vcfg model-changed
   break drop drop ;