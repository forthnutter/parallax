! Pin control starts here


USING: accessors arrays kernel models sequences ;

IN: parallax.pin 


TUPLE: pin < model number ;



: <pin> ( n -- pin )
    f pin new-model
    swap >>number ;


TUPLE: pins array ;

: pins-init ( array -- array' )
    [
        [ drop ] dip        ! get rid of element
        <pin>
    ] map-index ;

: <pins> ( n -- pins )
    pins new
    swap f <array> pins-init >>array ;
