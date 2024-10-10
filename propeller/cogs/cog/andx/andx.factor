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
    [ model-value dup ] dip ! value Value observ
    [ hold>> ] keep       ! value value hold observ
    [ bitand ] dip      ! value result obsev
    [ swap ] dip        ! result value obsev
    [ hold<< ] keep     ! result obser
    set-model
;





! init this object 
: <andx> ( value -- andx )
    ! break
    andx new-model
    0 >>hold
;