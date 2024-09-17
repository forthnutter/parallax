! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays ascii
        kernel io 
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

: l ( parallax address -- parallax )
    swap
    [
        propeller>> propeller-alist
        [ print ] each
    ] keep ;

: d ( parallax address cogn -- parallax )
    [
        [ propeller>> ] 2dip [ swap ] dip  ! address pro cogn 
        swap propeller-dump-cog
        [ print ] each
    ] 3keep 2drop ;

! display ina port hex
: ina-hex ( parallax cogn -- parallax )
    [
        [ propeller>> ] dip 
    ] 2keep drop ;



: <parallax> ( --  parallax )
    parallax new
    0 <24c256> >>at24
    <propeller> >>propeller
    [ [ at24>> ] [ propeller>> propeller-add-output ] bi ] keep ;