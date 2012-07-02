! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors ;
IN: parallax.propeller.emulator.cog

TUPLE: cog-memory < model n string ;

: <cog-memory> ( n value -- cog-memory )
   cog-memory new-model swap >>n ;


CONSTANT: COG_MEMORY_SIZE 496
CONSTANT: COG_SPR_SIZE    16


TUPLE: cog pc memory ;

: mem-setup ( -- vector )
   COG_MEMORY_SIZE f <array> dup
   [
      pick          ! get array
      swap dup      ! index
      0             ! value
      <cog-memory>
      swap          ! index
      pick          ! array
      set-nth
      drop drop
   ] each-index
   >vector dup
   496 0 <cog-memory> swap push dup
   497 0 <cog-memory> swap push dup
   498 0 <cog-memory> swap push dup
   499 0 <cog-memory> swap push dup
   500 0 <cog-memory> swap push dup
   501 0 <cog-memory> swap push dup
   502 0 <cog-memory> swap push dup
   503 0 <cog-memory> swap push dup
   504 0 <cog-memory> swap push dup
   505 0 <cog-memory> swap push dup
   506 0 <cog-memory> swap push dup
   507 0 <cog-memory> swap push dup
   508 0 <cog-memory> swap push dup
   509 0 <cog-memory> swap push dup
   510 0 <cog-memory> swap push dup
   511 0 <cog-memory> swap push dup
   ;

: reset ( cog -- cog )
    0 >>pc
;


: <cog> ( -- cog )
   cog new COG_MEMORY_SIZE f <array> >>memory reset
;


: read ( address cog -- value )
    memory>> nth
;

: write ( value address cog -- )
    memory>> set-nth
;