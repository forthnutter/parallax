! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;
IN: parallax.propeller.cogs.cog.memory

TUPLE: memory mread mwrite ;



GENERIC: read ( memory -- d )
GENERIC: write ( d memory -- )




M: memory read
   value>> ;

M: memory write
   mwrite>> set-model ;

M: memory model-changed
  drop drop ;

: add-memory-read ( object memory -- )
   mread>> add-connection
;

: add-memory-write ( object memory -- )
   mwrite>> add-connection ;

: <memory> ( value -- memory )
  memory new
  [ <model> ] dip swap >>mwrite
  [ 0 <model> ] dip swap >>mread ;
