! Protocol encoder for Parallax propeller

USING: kernel sequences byte-arrays bit-arrays math.bits grouping assocs
  combinators math math.bitwise ;


IN: parallax.propeller.protocol


TUPLE: protocol ;


GENERIC: encode ( array -- 'array )

! one bit hash
: encode-onebit ( n -- code )
  H{ { 0 0xFE } { 1 0xFF } }
  at ;

! two bit hash
: encode-twobit ( n -- code )
  H{
    { 0 0xF2 }
    { 1 0xF9 }
    { 2 0xFA }
    { 3 0xFD }
  }
  at ;

! three bit hash
: encode-threebit ( n -- code )
  H{
    { 0 0x92 } { 1 0xC9 }
    { 2 0xCA } { 3 0xE5 }
    { 4 0xD2 } { 5 0xE9 }
    { 6 0xEA } { 7 0xFA }
  }
  at ;

! four bit hash
: encode-fourbit ( n -- code )
  H{
    { 0 0x92 } { 1 0xC9 } { 2 0xCA } { 3 0x25 }
    { 4 0xD2 } { 5 0x29 } { 6 0x2A } { 7 0x95 }
    { 8 0x92 } { 9 0x49 } { 10 0x4A } { 11 0xA5 }
    { 12 0x52 } { 13 0xA9 } { 14 0xAA } { 15 0xD5 }
  }
  at ;

  ! five bit hash
  : encode-fivebit ( n -- code )
    H{
      { 0 0x92 } { 1 0xC9 } { 2 0xCA } { 3 0x25 }
      { 4 0xD2 } { 5 0x29 } { 6 0x2A } { 7 0x95 }
      { 8 0x92 } { 9 0x49 } { 10 0x4A } { 11 0xA5 }
      { 12 0x52 } { 13 0xA9 } { 14 0xAA } { 15 0xD5 }
      { 16 0x92 } { 17 0xC9 } { 18 0xCA } { 19 0x25 }
      { 20 0xD2 } { 21 0x29 } { 22 0x2A } { 23 0x95 }
      { 24 0x92 } { 25 0x49 } { 26 0x4A } { 27 0xA5 }
      { 28 0x52 } { 29 0xA9 } { 30 0xAA } { 31 0x55 }
    }
    at ;

: encode-bits ( array -- code )
  [ length ] keep swap
  {
    { 0 [ drop f ] }
    { 1 [ bit-array>integer encode-onebit ] }
    { 2 [ bit-array>integer encode-twobit ] }
    { 3 [ bit-array>integer encode-threebit ] }
    { 4 [ bit-array>integer encode-fourbit ] }
    [ drop bit-array>integer encode-fivebit ]
  } case ;

: long-send ( data -- code data )
  [ 4 mask 4 shift ] keep
  [ 2 mask 2 shift ] keep
  [ bitor ] dip
  [ 1 mask ] keep
  [ bitor ] dip
  [ 0x92 ] dip
  [ bitor ] dip ;

! PROPELLER HANDSHAKE SEQUENCE:
! The handshake (both Tx and Rx) are based on a
! Linear Feedback Shift Register (LFSR)
! tap sequence that repeats only after 255 iterations.
! The generating LFSR
: lfsr ( seed -- seed' ? )
  [ 0x01 bitand ] keep
  [ [ -1 shift ] [ -4 shift ] bi ] keep [ bitxor ] dip
  [ [ -5 shift ] [ -7 shift ] bi ] keep [ bitxor ] dip
  [ bitxor ] dip [ 0x01 bitand ] dip
  1 shift 0xFE bitand bitor swap ;

: encode-data ( array -- array' )
  dup byte-array?  ! make sure we have byte array
  [
    [ 8 <bits> ] V{ } map-as V{ } join >bit-array
    5 group
    [
      encode-bits
    ] map
  ] when ; ! we will return the original array if not byte
