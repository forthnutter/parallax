! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;
IN: parallax.propeller.emulator.cog.memory

TUPLE: cog-memory < model n string ;

: <cog-memory> ( n value -- cog-memory )
   cog-memory new-model swap >>n ;


GENERIC: OUTA ( cog-memory -- )
GENERIC: OUTB ( cog-memory -- )
GENERIC: DIRA ( cog-memory -- )
GENERIC: DIRB ( cog-memory -- )
GENERIC: CTRA ( cog-memory -- )
GENERIC: CTRB ( cog-memory -- )
GENERIC: FRQA ( cog-memory -- )
GENERIC: FRQB ( cog-memory -- )
GENERIC: PHSA ( cog-memory -- )
GENERIC: PHSB ( cog-memory -- )
GENERIC: VCFG ( cog-memory -- )
GENERIC: VSCL ( cog-memory -- )
! SYMBOL: VSCL

GENERIC: read ( cog-memory -- d )

CONSTANT: COG_MEMORY_SIZE 496
CONSTANT: COG_SPR_SIZE    16

M: cog-memory model-activated
   drop ;

M: cog-memory  model-changed
   drop drop
;



M: cog-memory OUTA
   drop
;

M: cog-memory OUTB
   drop
;

M: cog-memory DIRA
   drop
;

M: cog-memory DIRB
   drop
;

M: cog-memory CTRA
   drop
;

M: cog-memory CTRB
   drop
;

M: cog-memory FRQA
   drop
;

M: cog-memory FRQB
   drop
;

M: cog-memory PHSA
   drop
;

M: cog-memory PHSB
   drop
;

M: cog-memory VCFG
   drop
;

M: cog-memory VSCL
   drop
;


M: cog-memory read
   value>> ;



: add-cog-memory ( object memory -- memory )
   [ add-connection ] keep 
;


: cog-memory-par-init ( -- )
   ;
