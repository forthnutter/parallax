! Pin control starts here


USING: accessors arrays
    kernel
  
    math models
    parallax.at24c256
    parallax.propeller.inx
    parallax.propeller.outx
    sequences 
    tools.continuations ;

IN: parallax.ports


TUPLE: port in out dir vg cnta cntb ;






! write to in port
: port-in-write ( n port --  )
    in>> ?set-model ;

! or value to in port
: port-in-or ( n port -- )
    break
    in>>                    ! n model
    [ model-value ] keep    ! n value model
    [ bitor ] dip            ! or model
    ?set-model
;

! and value to in port
: port-in-and ( n port -- )
    break
    in>>            ! n model
    [ model-value ] keep    ! n value model
    [ bitand ] dip          ! and model
    ?set-model
;

! Read the in value
: port-in-read ( port -- in )
    in>> model-value    ! in
;

: port-add-connection ( observer port -- )
    add-connection ;

! add observer to port
: port-in-add-connection ( observer port --  )
    in>> port-add-connection ;

! add observer to out port
: port-out-add-connection ( observer port -- )
    out>> port-add-connection ;


! initilise port object
: <port> (  -- port )
    port new
    -1 <inx> >>in
    0 <outx> >>out
    0 <model> >>dir
;
