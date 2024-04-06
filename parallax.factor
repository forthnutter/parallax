! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays ascii
        kernel 
        math math.parser
        parallax.propeller
        parallax.propeller.hub
        parallax.propeller.cogs.cog
        parallax.at24c256
        sequences tools.continuations vectors ;


IN: parallax

TUPLE: parallax propeller at24 ;


: sx ( parallax --  parallax )
    [ propeller>> propeller-step ] keep
    [ propeller>> propeller-pc-alist ] keep
;

: x ( parallax -- parallax )
    [ propeller>> propeller-pc-alist ] keep ;

: r ( address cogn parallax -- parallax )
    [ propeller>> propeller-run-address ] keep ;

: <parallax> ( --  parallax )
    parallax new
    0 <24c256> >>at24
    <propeller> >>propeller
    [ [ at24>> ] [ propeller>> propeller-add-output ] bi ] keep ;