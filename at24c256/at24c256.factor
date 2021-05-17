! Lets make a emulation of a AT24C256 I2C Flash memory
! it has 256k bits 32k bytes
USING: accessors arrays kernel math.bitwise models ;

IN: parallax.at24c256

CONSTANT: AT24C256_SIZE 32767

TUPLE: 24c256 scl sda address array ;



! make a context 
! set the address of ths memory
: <24c256> ( address -- 24c256 )
    24c256 new              ! tuple memory
    t <model> >>scl         ! create model for clock in
    t <model> >>sda         ! create model for data
    swap 3 bits >>address   ! make sure only 3 bits save the address
    AT24C256_SIZE 0 <array> >>array ! allocate 32K byte memory
;