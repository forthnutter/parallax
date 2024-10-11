! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.orx

! orx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: orx < model hold input ;

: orx-dependecy ( orx -- )
    [ dependencies>> length 1 = ] keep swap
    [
        [ hold>> ] keep
        [
            dependencies>>
            [
                model-value bitor
            ] each
        ] keep set-model
    ]
    [ drop ] if ;


! a change is applied by external routine
M: orx model-changed
    break
    [ dependencies>> length 0 = ] keep swap
    [ drop drop ]
    [
        [ drop ] dip
        [ hold>> ] keep
        [ dependencies>> [ model-value bitor ] each ] keep
        set-model
     ] if ;

! add an observer to the orx
: orx-add-connection ( observer orx -- )
    add-connection ;

: orx-add-dependency ( dep orx -- )
    [ input>> push ] 2keep
    add-dependency ;

! init this object 
: <orx> ( value -- model )
    orx new-model 
    0 >>hold 
    V{ } clone >>input ;