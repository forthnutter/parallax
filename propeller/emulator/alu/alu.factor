! ALU words for parallax Propeller

USING: kernel accessors math math.bitwise ;

IN: parallax.propeller.emulator.alu



TUPLE: alu z c result ;


! return the z status
: alu-z ( alu -- ? )
  z>> ;

: alu-c ( alu -- ? )
  c>> ;

: alu-result ( alu -- d )
  result>> ;

! alu add
: alu-add ( a b alu -- alu )
  [ + ] dip swap >>result
  [ result>> ] keep swap 0 = >>z
  [ result>> ] keep swap 32 bit? >>c
;

! alu test
! bit wise and of two values
: alu-and ( a b alu -- alu )
  [ bitand ] dip swap >>result
  [ result>> ] keep swap 0 = >>z
  [ result>> ] keep swap odd-parity? >>c
;



! make a ALU Tuple to store stuff in
: <alu> ( -- alu )
  alu new ;
