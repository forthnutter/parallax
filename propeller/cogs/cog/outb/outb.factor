! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.outb

TUPLE: outb < model ;

: <outb> ( value -- outb )
   outb new-model ;

M: outb model-changed
   break drop drop ;
