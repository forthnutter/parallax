! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig
        parallax.propeller.flexbuffer io.pathnames ;

IN: parallax.propeller.pathentry

SYMBOL: end
SYMBOL: entry



: AddFilePath ( name -- ? )
    <pathname> end set     
    end get
    [
        entry get vector?
        [
            end get
            entry get push
            t
        ]
        [ f ] if
    ]
    [ f ] if
;

: <pathentry> ( -- )
    V{ } clone entry set
;
