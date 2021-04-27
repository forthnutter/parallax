! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models
   vectors tools.continuations parallax.propeller.cogs.cog.memory ;

IN: parallax.propeller.cogs.cog.out

TUPLE: out < model ;


: out-read ( out -- data )
   value>> ;

: out-write ( data out -- )
   set-model ;

M: out model-changed
   drop drop ;
   

: <out> ( value -- out )
   out new-model ;
