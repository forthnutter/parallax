! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.andx

! andx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: andx < model previous ;

! generics for read and write
GENERIC: and-read ( andx -- d )
GENERIC: and-write ( d andx -- )


! Just read the value
M: andx and-read
   value>> ;

! lets write
M: andx and-write
    [ and-read bitor ] keep
   set-model ;

! a change is applied by external routine
M: andx model-changed
    break
    [
        [ model-value ] dip
        [ model-value ] keep
        [ bitand ] dip
    ]
    set-model ;  ! this will change obsevers

! function add a model to orx input to or
: andx-dependency ( dep andx -- )
    add-dependency ;

: andx-activate ( andx -- )
    activate-model ;

! init this object 
: <andx> ( value -- andx )
    dup
    andx new-model
    [ previous<< ] keep ;