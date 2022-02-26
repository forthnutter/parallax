! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;
IN: parallax.propeller.cogs.cog.memory

TUPLE: memory < model ;


: memory-read ( memory -- data )
   value>> ;

: memory-write ( d memory -- )
   set-model ;

M: memory model-changed
  drop drop ;

: add-memory-read ( object memory -- )
   add-connection
;

: add-memory-write ( object memory -- )
   add-connection ;

: memory-add-dependency ( object memory -- )
   add-dependency ;

: memory-activate ( memory -- )
   activate-model ;

: <memory> ( value -- memory )
  memory new-model ;
