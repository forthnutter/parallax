! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models
   vectors tools.continuations
   ;

IN: parallax.propeller.outx

TUPLE: outx < model ;


: outx-read ( out -- data )
   value>> ;

: outx-write ( data out -- )
   break
   set-model ;

M: outx model-changed
   [ value>> ] dip ! get memory value
   outx-write         ! send it out we may have others
;


: <outx> ( value -- out )
   outx new-model ;
