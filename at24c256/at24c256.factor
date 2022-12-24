! Lets make a emulation of a AT24C256 I2C Flash memory
! it has 256k bits 32k bytes
USING: accessors arrays byte-vectors
        tools.continuations kernel math math.bitwise models ;

IN: parallax.at24c256

CONSTANT: AT24C256_SIZE 32767

TUPLE: 24c256 < model data clock sda scl tdata byte mask address array ;

! modify bit 0 of x using status and return result
: bit-zero ( x ? -- a )
    [ 0 set-bit ]
    [ 0 clear-bit ]
    if ;

: data-shift ( t -- d )
    [ data>> ] keep
    [ 1 shift ] dip
    [ data<< ] keep data>> ;

: clock-shift ( t -- d )
    [ clock>> ] keep
    [ 1 shift ] dip
    [ clock<< ] keep clock>> ;


M: 24c256 model-changed
   break
    [ [ value>> ] [ sda>> ] bi* ] 2keep
    [ bit? ] 2dip [ data-shift ] keep swap roll        ! x y ?
    bit-zero swap [ data<< ] keep

    [ [ value>> ] [ scl>> ] bi* ] 2keep
    [ bit? ] 2dip [ clock-shift ] keep swap roll       ! x y ?
    bit-zero swap [ clock<< ] keep

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