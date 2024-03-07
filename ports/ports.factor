! Pin control starts here


USING: accessors arrays kernel models parallax.at24c256
        sequences ;

IN: parallax.ports


TUPLE: port < model number ;



: <port> ( n -- port )
    f port new-model
    swap >>number ;


TUPLE: ports array ;

! get the model for pin number n
: ports-getport ( n port -- model )
    array>> ?nth ;

! add an observer to pin model
: ports-observer ( n observer ports -- )
    [ swap ] dip ! observer n ports
    ports-getport     ! obsever ports
    add-connection ;

: ports-init ( array -- array' )
    [
        [ drop ] dip        ! get rid of element
        <port>
    ] map-index
    [ 29 swap nth 0 <24c256> swap add-connection ] keep ;

! create the number of bit ports
: <ports> ( n -- ports )
    ports new
    swap f <array> ports-init >>array ;
