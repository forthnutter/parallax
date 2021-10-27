! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig parallax.propeller.flexbuffer ;
IN: parallax.propeller.preprocess


TUPLE: preprocess file line whole defs ifs linecomment startcomment endcomment
                incomment messagefunc alternate loadfile freefile ;



: default_messagefunc ( -- )

;

: pp-set-file-func ( loadfile freefile pp -- pp )
    swap >>freefile
    swap >>loadfile
;



: <preprocess> ( alt -- pp )

    preprocess new

    128 <flexbuffer> >>line
    102400 <flexbuffer> >>whole

    \ default_messagefunc >>messagefunc
    swap >>alternate
;


