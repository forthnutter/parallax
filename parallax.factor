! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays ascii
        kernel 
        math math.parser
        parallax.propeller
        parallax.propeller.hub
        parallax.propeller.cogs.cog
        sequences tools.continuations vectors ;


IN: parallax

TUPLE: parallax propeller ;


: sx ( parallax --  parallax )
    [ propeller>> propeller-step ] keep
    [ propeller>> propeller-pc-alist ] keep
;

: <parallax> ( --  parallax )
    parallax new
    <propeller> >>propeller ;