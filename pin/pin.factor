! Pin control starts here


USING: kernel ;

IN: parallax.pin 


TUPLE: pin < model number ;



: <pin> ( n -- pin )
    f pin new-model
    swap >>number ;


TUPLE: pins array ;

: pins-init ( array -- array' )
    [ <pin> ] map ;

: <pins> ( n -- pins )
    pins new
    f <array> pins-init >>array ;
