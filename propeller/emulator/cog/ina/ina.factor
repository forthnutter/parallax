! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.ina

TUPLE: ina < model ;

: <ina> ( value -- ina )
   ina new-model ;

M: ina model-changed
   break drop drop ;