! Pin control starts here


USING: accessors arrays kernel models sequences ;

IN: parallax.pin 


TUPLE: pin < model number ;



: <pin> ( n -- pin )
    f pin new-model
    swap >>number ;


TUPLE: pins array ;

! get the model for pin number n
: pins-getpin ( n pins -- model )
    array>> ?nth ;

! add an observer to pin model
: pins-observer ( n observer pins -- )
    [ swap ] dip ! observer n pins
    pins-getpin     ! obsever pin
    add-connection ;

: pins-init ( array -- array' )
    [
        [ drop ] dip        ! get rid of element
        <pin>
    ] map-index ;

: <pins> ( n -- pins )
    pins new
    swap f <array> pins-init >>array ;
