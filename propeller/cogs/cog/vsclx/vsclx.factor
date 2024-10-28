! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.vsclx

TUPLE: vsclx < model ;


: vsclx-add-connection ( obsever vsclx -- )
    add-connection ;

: vsclx-add-dependency ( dep vscl -- )
    add-dependency ;

: <vsclx> ( value -- vscl )
   vsclx new-model ;