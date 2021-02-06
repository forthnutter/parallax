! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;
IN: parallax.propeller.cogs.cog.memory

TUPLE: memory < model ;



GENERIC: read ( memory -- d )
GENERIC: write ( d memory -- )




M: memory read
   value>> ;

M: memory write
   set-model ;

M: memory model-changed
  drop drop ;

: add-memory ( object memory -- )
   add-connection
;

: <memory> ( value -- memory )
  memory new-model ;
