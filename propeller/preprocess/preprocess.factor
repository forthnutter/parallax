! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig  ;
IN: parallax.propeller.preprocess


TUPLE: preprocess file line whole defs ifs linecomment startcomment endcomment
                incomment messagefunc alternate ;



: default_messagefunc ( -- )

;


: <preprocess>( alt -- pp )

    preprocess new

    128 <flexbuffer> >>line
    102400 <flexbuffer> >>whole

    \ default_messagefunc >>messagefunc
    swap >>alternate
;


