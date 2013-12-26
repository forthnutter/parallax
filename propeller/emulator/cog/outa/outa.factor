! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.emulator.cog.outa

TUPLE: outa < model ;

: <outa> ( value -- outa )
   outa new-model ;

M: outa model-changed
   break drop drop ;