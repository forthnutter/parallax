! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models
   vectors tools.continuations
   ;

IN: parallax.propeller.outx

TUPLE: outx < model cogn ;


: outx-read ( out -- data )
   model-value ;

: outx-write ( data out -- )
   set-model ;

M: outx model-changed
    break
   [ value>> ] dip ! get memory value
   outx-write         ! send it out we may have others
;

! add object to observe output
: outx-add-connection ( observer outx -- )
    add-connection ;

: <outx> ( value -- out )
   0 outx new-model swap >>cogn ;
