! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models math.bitwise
        vectors tools.continuations ;
IN: parallax.propeller.cogs.cog.memory

TUPLE: memory < model ;


GENERIC: read ( memory -- data )

M: memory read
   model-value 32 bits ;

: memory-read ( memory -- data )
   model-value ;

: memory-write ( d memory -- )
   set-model ;

M: memory model-changed
    [ model-value ] dip  set-model ;

: memory-add-read-connection ( object memory -- )
   add-connection
;

: add-memory-write ( object memory -- )
   add-connection ;

: memory-add-dependency ( object memory -- )
   add-dependency ;

: memory-activate ( memory -- )
   activate-model ;

: memory-deactivate ( memory -- )
   deactivate-model ;

! create a memory model
: <memory> ( value -- memory )
  memory new-model ;
