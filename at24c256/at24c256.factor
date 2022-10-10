! Lets make a emulation of a AT24C256 I2C Flash memory
! it has 256k bits 32k bytes
USING: accessors arrays byte-vectors
        tools.continuations kernel math math.bitwise models ;

IN: parallax.at24c256

CONSTANT: AT24C256_SIZE 32767

TUPLE: 24c256 < model data clock sda scl tdata byte mask address array ;


M: 24c256 model-changed
   break
    [ [ value>> ] [ sda>> ] bi* ] 2keep
    [ bit? ] 2dip rot        ! x y ?
    [
        [ data>> 1 shift 0 set-bit ] keep
        [ data<< ] keep
    ]
    [
        [ data>> 1 shift 0 clear-bit ] keep
        [ data<< ] keep
    ] if 
    [ [ value>> ] [ scl>> ] bi* ] 2keep
    [ bit? ] 2dip rot        ! x y ?
    [
        [ clock>> 1 shift 0 set-bit ] keep
        [ clock<< ] keep
    ]
    [
        [ clock>> 1 shift 0 clear-bit ] keep
        [ clock<< ] keep
    ] if 
    [ value>> ] dip set-model ;

! make a context 
! set the address of ths memory
: <24c256> ( address -- 24c256 )
    0 24c256 new-model              ! tuple memory
    swap 3 bits >>address   ! make sure only 3 bits save the address
    29 >>sda                ! bit number to scan for data
    28 >>scl                ! bit number to scan for clock
    AT24C256_SIZE 0 <array> >>array ! allocate 32K byte memory
    8 <byte-vector> >>tdata
    0 >>byte
    0 >>mask
    0 >>data
    0 >>clock 
;