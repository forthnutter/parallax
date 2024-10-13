! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays combinators kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.andx

! andx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: andx < model hold ;




! a change is applied by external routine
M: andx model-changed
    break
    [ dependencies>> length 0 = ] keep swap
    [
        [ model-value ] dip
        [ hold>> ] keep
        [ bitand ] dip
        set-model
    ]
    [
        [ drop ] dip
        [ hold>> ] keep
        [ dependencies>> [ model-value bitand ] each ] keep
        set-model
    ] if
;


! add an observer to the andx
: andx-add-connection ( observer andx -- )
    add-connection ;

: andx-add-dependency ( dep andx -- )
    add-dependency ;


! init this object 
: <andx> ( value -- andx )
    ! break
    andx new-model
    -1 >>hold
;