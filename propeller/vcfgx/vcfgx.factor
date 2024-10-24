! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.vcfgx

TUPLE: vcfgx < model ;



M: vcfgx model-changed
   break drop drop ;

: vcfgx-dependency ( dep vcfgx -- )
    add-dependency ;

: <vcfgx> ( value -- par )
   vcfgx new-model ;