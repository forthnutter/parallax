! Pin control starts here


USING: accessors arrays kernel models parallax.at24c256
        sequences ;

IN: parallax.ports


TUPLE: port in out dir ;

! write to in port
: port-in-write ( n port --  )
    in>> ?set-model ;

! or value to in port
: port-in-or ( n port -- )
    in>>        ! n model
    [ model-value ] keep    ! n value model
    [ bit-or ] keep         ! or model
    ?set-model
;


: <port> (  -- port )
    port new
    0 <model> >>in
    0 <model> >>out
    0 <model> >>dir
;
