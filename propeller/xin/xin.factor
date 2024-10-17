! Copyright (C) 2024 Forthnutter.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors kernel models sequences math
   math.bitwise math.parser tools.continuations arrays ;

IN: parallax.propeller.xin



! inx can be INA and INB 
! and lets combine model object
TUPLE: xin < model out ddr in ;

M: xin model-changed
    break
    [ drop ] dip
    [ [ out>> ] [ ddr>> ] [ in>> ] tri ] keep
    [ or or ] dip swap
    [
        [ [ in>> model-value ] [ ddr>> model-value bitnot ] bi ] keep
        [ bitand ] dip
        [ [ out>> model-value ] [ ddr>> model-value ] bi ] keep
        [ bitand ] dip
        [ bitor ] dip set-model
    ]
    [ drop ] if ;

    
    

: <xin> ( in out ddr n -- xin )
    xin new-model
    [ ddr<< ] keep
    [ out<< ] keep
    [ in<<  ] keep ;
