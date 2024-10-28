! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.frqx

TUPLE: frqx < model ;


: frqx-add-connection ( observer frqx -- )
    add-connection ;

: frqx-add-dependency ( dep frqx -- )
    add-dependency ;


: <frqx> ( value -- frqx )
   frqx new-model ;

