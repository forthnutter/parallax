! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.orx

! orx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: orx < model previous ;


! a change is applied by external routine
M: orx model-changed
    break
    [ model-value ] dip
    [ model-value ] keep
    [ bitor ] dip
    set-model ;

! add an observer to the orx
: orx-add-connection ( observer orx -- )
    add-connection ;

! init this object 
: <orx> ( value -- model )
    dup
    orx new-model 
    [ previous<< ] keep ;