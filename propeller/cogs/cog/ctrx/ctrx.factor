! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.ctrx

TUPLE: ctrx < model ;


: ctrx-add-connection ( observer ctrx -- )
    add-connection ;

: ctrx-add-dependency ( dep ctrx -- )
    add-dependency ;


: <ctrx> ( value -- ctrx )
   ctrx new-model ;


