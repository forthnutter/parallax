! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig parallax.propeller.flexbuffer ;

IN: parallax.propeller.pathentry


TUPLE: pathentry entry ;

! create an new path entry
: makenextpath( pathentry name -- ? )



;