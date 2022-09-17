! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays ascii
        kernel parallax.propeller.cogs.cog
        math math.parser parallax.propeller.hub
        sequences tools.continuations vectors ;


IN: parallax




: <parallax> ( --  hub )
    <hub> ;