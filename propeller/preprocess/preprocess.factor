! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig parallax.propeller.flexbuffer ;
IN: parallax.propeller.preprocess

SYMBOL: s_pLoadFileFunc
SYMBOL: s_pFreeFileBufferFunc 
SYMBOL: pre-process

TUPLE: preprocess fil line whole defs ifs linecomment
    startcomment endcomment incomment messagefunc
    alternate ;
    

: default_messagefunc ( -- )

;

: pp-setfilefunctions ( loadfile freefile -- )
    s_pFreeFileBufferFunc set
    s_pLoadFileFunc set
;

! *
! * set comment characters
! *
: pp_setcomments ( pp line start end -- )
    [ [ preprocess? ] keep swap ] 3dip roll
    [
        [ >>linecomment ] 2dip
        [ >>startcomment ] dip
        >>endcomment drop
    ]
    [ 4drop ] if ;


! *
! * initialize preprocessor
! *
: pp_init ( pp alternate -- )

!    memset(pp, 0, sizeof(*pp));
    [ [ preprocess? ] keep swap ] dip swap
    [
        swap
        128 <vector> >>line
        102400 <vector> >>whole
        \ default_messagefunc >>messagefunc
        alternate<<
    ]
    [
        drop
        drop
    ] if

;
