! build data to be sent to Parallax propeller

USING: kernel sequences byte-arrays bit-arrays math.bits grouping assocs combinators
    binfile ;


IN: parallax.propeller.upload

SYMBOL: pload-delay

: make-long ( data -- array )
  4 >be ;


: send-long ( type -- ? )
  pload-delay
  [ make-long ]
  [  ] if

! lets upload file to the Propeller
: upload ( type filename -- array )

  <binfile> ;
