! ALU words for parallax Propeller

USING: kernel accessors math math.bitwise ;

IN: parallax.propeller.cogs.alu



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

! alu add
: alu-or ( a b alu -- alu )
  [ bitor ] dip swap >>result
  [ result>> ] keep swap 0 = >>z
  [ result>> ] keep swap odd-parity? >>c
;


! alu update flags and result
: alu-update ( a b alu -- alu )
  swap >>result      ! just put b into reult
  [ drop ] dip  ! don't need a
  [ result>> ] keep swap 0 = >>z
  [ result>> ] keep swap 31 bit? >>c
;

! subtract
: alu-sub ( a b alu -- alu )
  [ - ] dip swap >>result
  [ result>> ] keep swap 0 = >>z
  [ result>> ] keep swap -1 = >>c
;

! absolute values
: alu-abs ( a b alu -- alu )
  [ swap 32 bit? >>c drop ] 2keep
  [ 32 >signed abs ] dip swap >>result
  [ drop ] dip
  [ result>> ] keep swap 0 = >>z ;

! make a ALU Tuple to store stuff in
: <alu> ( -- alu )
  alu new ;
