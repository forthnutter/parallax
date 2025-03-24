! ALU words for parallax Propeller

USING: kernel accessors math math.bitwise 
    tools.continuations ;

IN: parallax.propeller.cogs.alu



TUPLE: alu z c result lc ;


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

! alu or
: alu-or ( a b alu -- alu )
  [ bitor ] dip swap >>result
  [ result>> ] keep swap 0 = >>z
  [ result>> ] keep swap odd-parity? >>c
;

! alu xor
: alu-xor ( a b alu -- alu )
  [ bitxor ] dip swap >>result
  [ result>> ] keep swap 0 = >>z
  [ result>> ] keep swap odd-parity? >>c
;

! MUXC sets each bit of the value in Destination, which corresponds to Mask’s high (1) bits,
! to the C state. All bits of Destination that are not targeted by high (1) bits of Mask are
! unaffected.
! If the WZ effect is specified, the Z flag is set (1) if Destination’s final value is 0.
! If the WC effect is specified, the C flag is set (1) if the resulting Destination contains
! an odd number of high (1) bits.
: alu-muxc ( a b alu -- alu )
    [ alu-c ] keep swap
    [ [ mask ] dip ] [ [ bitnot mask ] dip ] if
    swap >>result
    [ result>> ] keep swap 0 = >>z 
    [ result>> ] keep swap odd-parity? >>c 
;

! MUXZ sets each bit of the value in Destination, which corresponds to Mask’s high (1) bits,
! to the Z state. All bits of Destination that are not targeted by high (1) bits of Mask are
! unaffected.
! If the WZ effect is specified, the Z flag is set (1) if Destination’s final value is 0.
! If the WC effect is specified, the C flag is set (1) if the resulting Destination contains
! an odd number of high (1) bits.
: alu-muxz ( a b alu -- alu )
    [ alu-z ] keep swap
    [ [ mask ] dip ] [ [ bitnot mask ] dip ] if
    swap >>result
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

! shift left function
: alu-shl ( a b alu -- alu )
    [ shift ] dip swap >>result
    [ result>> ] keep swap 0 = >>z 
    [ result>> ] keep swap 32 bit? >>c 
;

! Rotate carry left function
: alu-rcl ( a b alu -- alu )
    [ dup 31 bit? ] 2dip [ [ swap ] dip lc<< ] keep ! here we save bit 31
    [ c>> ] keep swap       ! now get the carry flag
    [ [ 0xFFFFFFFF00000000 bitor ] 2dip ] ! this should work
    [ [ 0x00000000FFFFFFFF bitand ] 2dip ] ! rotate carry bits into lsb
    if 
    [ bitroll-64 32 bits ] dip swap >>result
    [ result>> ] keep swap 0 = >>z
;


! make a ALU Tuple to store stuff in
: <alu> ( -- alu )
  alu new ;
