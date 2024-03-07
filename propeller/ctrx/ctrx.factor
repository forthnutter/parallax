! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.ctrx

TUPLE: ctrx < model ;



M: ctrx model-changed
   break drop drop ;

: ctrx-dependency ( dep ctrx -- )
    add-dependency ;


: <ctrx> ( value -- par )
   ctrx new-model ;


