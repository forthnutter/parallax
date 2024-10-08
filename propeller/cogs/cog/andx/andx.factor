! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.andx

! andx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: andx < model ip-vector anda andb ;


TUPLE: and-input < model ;


: <and-input> ( value -- andix )
    and-input new-model ;

M: and-input model-changed
    break
    [ model-value ] dip 
    ?set-model ;

! a change is applied by external routine
M: andx model-changed
    break
    [ drop ] dip
    [ ip-vector>> ] keep swap
    [ ?second ] keep swap
    [

    ]
    [ bitand ] dip
    set-model
;

: andx-anda ( andx -- anda )
    anda>> ;

: andx-andb ( andx -- andb )
    andb>> ;

: andx-add-input ( model andx -- )
    [ swap add-connection ] 2keep           ! make andx an observer of the model
    ip-vector>> push ;

: andx-input ( andx -- andx-input )
    0 <and-input> swap [ dup ] dip andx-add-input ;


! init this object 
: <andx> ( value -- andx )
    ! break
    andx new-model
    V{ } clone >>ip-vector
    0 <and-input> >>anda
    [ [ anda>> ] keep swap add-connection ] keep
    0 <and-input> >>andb 
    [ [ andb>> ] keep swap add-connection ] keep ;