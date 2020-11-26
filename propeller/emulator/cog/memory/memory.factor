! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;
IN: parallax.propeller.emulator.cog.memory

TUPLE: memory < model n string ;



GENERIC: read ( memory -- d )
GENERIC: write ( d memory -- )

CONSTANT: MEMORY_SIZE 512
CONSTANT: SPR_SIZE    16


M: memory read
   value>> ;

M: memory write
   set-model ;

M: memory model-changed
  drop drop ;

: add-memory ( object memory -- memory )
   [ add-connection ] keep
;

: <memory> ( n value -- memory )
  memory new-model
  [ dup add-connection ] keep
  swap >>n ;
