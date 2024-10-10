! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.orx

! orx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: orx < model hold input ;


! a change is applied by external routine
M: orx model-changed
    break
    [ model-value dup ] dip ! value value obsev 
    [ hold>> ] keep         ! value value hold obsev
    [ bitor ] dip           ! value or obsev
    [ swap ] dip            ! or value observ
    [ hold<< ] keep         ! or observ
    set-model ;

! add an observer to the orx
: orx-add-connection ( observer orx -- )
    [ input>> push ] 2keep
    add-connection ;

! init this object 
: <orx> ( value -- model )
    orx new-model 
    0 >>hold 
    V{ } clone >>input ;