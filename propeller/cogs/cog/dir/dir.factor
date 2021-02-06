! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.dir

TUPLE: dir < model ;

: <dir> ( value -- dira )
   dir new-model ;

M: dir model-changed
   break drop drop ;
