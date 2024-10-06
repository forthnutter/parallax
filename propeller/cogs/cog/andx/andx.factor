! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.andx

! andx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: andx < model anda andb ;


TUPLE: andix < model ;


: <andix> ( value -- andix )
    andix new-model ;

M: andix model-changed
    break
    [ model-value ] dip 
    ?set-model ;

! a change is applied by external routine
M: andx model-changed
    break
    [ drop ] dip
    [ [ anda>> model-value ] [ andb>> model-value ] bi ] keep
    [ bitand ] dip
    set-model
;

: andx-anda ( andx -- anda )
    anda>> ;

: andx-andb ( andx -- andb )
    andb>> ;


! init this object 
: <andx> ( value -- andx )
    break
    andx new-model
    0 <andix> >>anda
    [ [ anda>> ] keep swap add-connection ] keep
    0 <andix> >>andb 
    [ [ andb>> ] keep swap add-connection ] keep ;