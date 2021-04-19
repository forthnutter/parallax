! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models
   vectors tools.continuations parallax.propeller.cogs.cog.memory ;

IN: parallax.propeller.cogs.cog.out

TUPLE: out value ;

GENERIC: read ( out -- data )
GENERIC: out-write ( data out -- )

M: memory read
   value>> ;

M: memory out-write
    ;

: <out> ( value -- out )
   out new >>value ;
