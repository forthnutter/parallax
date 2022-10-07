! Lets make a emulation of a AT24C256 I2C Flash memory
! it has 256k bits 32k bytes
USING: accessors arrays byte-vectors
        tools.continuations kernel math.bitwise models ;

IN: parallax.at24c256

CONSTANT: AT24C256_SIZE 32767

TUPLE: 24c256 < model data clock sda scl data byte mask address array ;


M: 24c256 model-changed
   break
   [ value>> ] dip set-model ;

! make a context 
! set the address of ths memory
: <24c256> ( address -- 24c256 )
    0 24c256 new-model              ! tuple memory
    swap 3 bits >>address   ! make sure only 3 bits save the address
    29 >>data                ! bit number to scan for data
    28 >>clock               ! bit number to scan for clock
    AT24C256_SIZE 0 <array> >>array ! allocate 32K byte memory
    8 <byte-vector> >>data
    0 >>byte
    0 >>mask 
;