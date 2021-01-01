! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors
       parallax.propeller.emulator.cog.memory
       parallax.propeller.emulator.cog.par
       parallax.propeller.emulator.cog.cnt
       parallax.propeller.emulator.cog.ina
       parallax.propeller.emulator.cog.inb
       parallax.propeller.emulator.cog.outa
       parallax.propeller.emulator.cog.outb
       parallax.propeller.emulator.cog.dira
       parallax.propeller.emulator.cog.dirb
       parallax.propeller.emulator.cog.ctr
       parallax.propeller.emulator.cog.frqa
       parallax.propeller.emulator.cog.frqb
       parallax.propeller.emulator.cog.phsa
       parallax.propeller.emulator.cog.phsb
       parallax.propeller.emulator.cog.vcfg
       parallax.propeller.emulator.cog.vscl
       math math.bitwise math.parser alien.syntax combinators
       io.binary grouping intel.hex bit-arrays bit-vectors
       parallax.propeller.emulator.alu tools.continuations
       parallax.propeller.emulator.cogdisasm ascii
;

IN: parallax.propeller.emulator.cog

! Constants
CONSTANT: COG_INACTIVE                  0
CONSTANT: COG_EXECUTE_FETCH             1
CONSTANT: COG_RESULT                    2
CONSTANT: COG_FETCH_SOURCE              3
CONSTANT: COG_FETCH_DEST                4


CONSTANT: COG_START_ISN                 0

CONSTANT: NEVER        0
CONSTANT: IF_NC_AND_NZ 1
CONSTANT: IF_NZ_AND_NC 1
CONSTANT: IF_A         1
CONSTANT: IF_NC_AND_Z  2
CONSTANT: IF_Z_AND_NC  2
CONSTANT: IF_NC        3
CONSTANT: IF_AE        3
CONSTANT: IF_C_AND_NZ  4
CONSTANT: IF_NZ_AND_C  4
CONSTANT: IF_NZ        5
CONSTANT: IF_NE        5
CONSTANT: IF_C_NE_Z    6
CONSTANT: IF_Z_NE_C    6
CONSTANT: IF_NC_OR_NZ  7
CONSTANT: IF_NZ_OR_NC  7
CONSTANT: IF_C_AND_Z   8
CONSTANT: IF_Z_AND_C   8
CONSTANT: IF_C_EQ_Z    9
CONSTANT: IF_Z_EQ_C    9
CONSTANT: IF_Z         10
CONSTANT: IF_E         10
CONSTANT: IF_NC_OR_Z   11
CONSTANT: IF_Z_OR_NC   11
CONSTANT: IF_C         12
CONSTANT: IF_B         12
CONSTANT: IF_C_OR_NZ   13
CONSTANT: IF_NZ_OR_C   13
CONSTANT: IF_C_OR_Z    14
CONSTANT: IF_Z_OR_C    14
CONSTANT: IF_BE        14
CONSTANT: ALLWAYS      15

CONSTANT: CJMP         23   ! 0x17
CONSTANT: CALL         23
CONSTANT: CJMPRET      23
CONSTANT: CRET         23
CONSTANT: CAND         24   ! 0x18
CONSTANT: CTEST        24
CONSTANT: CANDN        25   ! 0x19
CONSTANT: COR          26   ! 0x20
CONSTANT: CMOV         40   ! 0x28
CONSTANT: CABS         42   ! 0x2A
CONSTANT: CDJNZ        57   ! 0x39



! tuple to hold cog stuff
TUPLE: cog pc alu z c memory state isn fisn source dest result bp mneu ;


: cog-memory ( address cog -- memory )
   memory>> nth ;


: cog-setup ( -- vector )
   MEMORY_SIZE f <array> dup
   [
      pick          ! get array
      swap dup      ! index
      0             ! value
      <memory>
      swap          ! index
      pick          ! array
      set-nth
      drop drop
   ] each-index
   >vector ;


! add the special function registers to memory
: cog-sfr ( cog -- )
   ! special purpose registers
   [ 496 swap cog-memory ] keep swap 0 <par> swap add-memory ! Boot Parameter
   [ 497 swap cog-memory ] keep swap 0 <cnt> swap add-memory ! System counter
   [ 498 swap cog-memory ] keep swap 0 <ina> swap add-memory ! Port A input
   [ 499 swap cog-memory ] keep swap 0 <inb> swap add-memory ! Port B input
   [ 500 swap cog-memory ] keep swap 0 <outa> swap add-memory ! Port A out
   [ 501 swap cog-memory ] keep swap 0 <outb> swap add-memory ! Port B out
   [ 502 swap cog-memory ] keep swap 0 <dira> swap add-memory ! Port A Direction
   [ 503 swap cog-memory ] keep swap 0 <dirb> swap add-memory ! Port B Direction
   [ 504 swap cog-memory ] keep swap 0 <ctr> swap add-memory ! Counter A control
   [ 505 swap cog-memory ] keep swap 0 <ctr> swap add-memory ! Counter B control
   [ 506 swap cog-memory ] keep swap 0 <frqa> swap add-memory ! Counter A freq
   [ 507 swap cog-memory ] keep swap 0 <frqb> swap add-memory ! Counter B freq
   [ 508 swap cog-memory ] keep swap 0 <phsa> swap add-memory ! Counter A phase
   [ 509 swap cog-memory ] keep swap 0 <phsb> swap add-memory ! Counter B phase
   [ 510 swap cog-memory ] keep swap 0 <vcfg> swap add-memory ! Video Configuration
   [ 511 swap cog-memory ] keep swap 0 <vscl> swap add-memory ! Video Scale
   drop ;

: cog-reset ( cog -- )
  0 >>pc COG_START_ISN >>isn
  COG_INACTIVE >>state
  drop ;

! increment PC
: PC+ ( cog -- ) [ pc>> 1 + ] keep pc<< ;


! decrement PC
: PC- ( cog -- ) [ pc>> 1 - ] keep pc<< ;


: cog-read ( address cog -- d )
  cog-memory read ;

: cog-read-array ( n address cog -- array )
  [ f <array> ] 2dip rot
  [
    drop
    [ cog-read ] 2keep [ 1 + ] dip rot
  ] map [ drop drop ] dip ;

: cog-write ( value address cog -- )
  cog-memory write ;

! make cog active
: cog-active ( cog -- )
  COG_EXECUTE_FETCH >>state drop ;

: cog-set-state ( state cog -- )
  swap state<< ;

! return the status if the immediate flag
: cog-isn-i ( cog -- ? )
  isn>> 22 bit? ;

: cog-source-address ( cog -- address )
  isn>> 8 0 bit-range ;

: cog-source-value ( cog -- value )
  [ cog-source-address ] keep cog-read ;

: cog-fetch-source ( cog -- source )
  [ cog-isn-i ] keep swap
  [ cog-source-address ] ! immeadiate
  [ cog-source-value ] if ;

: cog-dest-address ( cog -- address )
  isn>> 17 9 bit-range ;

: cog-fetch-dest ( cog -- value )
  [ cog-dest-address ] keep cog-read ;

! extrac the conditional code
: isn-cond ( isn -- cond )
  21 18 bit-range ;

: cog-state-z ( cog -- ? )
  z>> ;

: cog-state-nz ( cog -- ? )
  z>> not ;

: cog-isn-code ( cog -- code )
  isn>> 31 26 bit-range ;

: cog-and ( cog -- )
  [ [ dest>> ] [ source>> ] bi ] keep
  alu>> alu-and drop ;

: cog-andn ( cog -- )
  [ [ dest>> ] [ source>> bitnot 32 bits ] bi ] keep
  alu>> alu-and drop ;


: cog-or ( cog -- )
  [ [ dest>> ] [ source>> ] bi ] keep
  alu>> alu-or drop ;


: cog-jump ( cog -- )
  [ dest>> 0b111111111 unmask ] keep
  [ pc>> bitor 0 ] keep
  [ alu>> alu-add drop ] keep
  [ source>> ] keep pc<< ;


: cog-mov ( cog -- )
  [ dest>> ] keep
  [ source>> ] keep
  alu>> alu-update drop ;

: cog-djnz ( cog -- )
  [ dest>> 1 ] keep
  [ alu>> alu-sub ] keep swap
  alu-z not
  [ [ source>> ] keep pc<< ] [ drop ] if ;


: cog-abs ( cog -- )
  [ dest>> ] keep
  [ source>> ] keep
  alu>> alu-abs drop ;


: cog-exec-condition ( cog -- )
  break
  [ cog-isn-code ] keep swap
  {
    { CJMP [ cog-jump ] }
    { CAND [ cog-and ] }
    { CANDN [ cog-andn ] }
    { COR [ cog-or ] }
    { CMOV [ cog-mov ] }
    { CABS [ cog-abs ] }
    { CDJNZ [ cog-djnz ] }
    [ break drop drop ]
  } case
;

: cog-execute-ins ( cog -- )
  [ isn>> isn-cond ] keep swap
  {
    { NEVER [ break drop ] } ! yes do nothing
    { IF_NC_AND_NZ
      [
        [ [ c>> not ] [ z>> not ] bi and ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_NC_AND_Z
      [
        [ [ c>> not ] [ z>> ] bi and ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_NC
      [
        [ c>> not ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_C_AND_NZ
      [
        [ [ c>> ] [ z>> not ] bi and ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_NZ
      [
        [ z>> not ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_C_NE_Z
      [
        [ [ c>> ] [ z>> ] bi = not ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_NC_OR_NZ
      [
        [ [ c>> not ] [ z>> not ] bi or ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_C_AND_Z
      [
        [ [ c>> ] [ z>> ] bi and ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_C_EQ_Z
      [
        [ [ c>> ] [ z>> ] bi = ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_Z
      [
        [ z>> not ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    { IF_NC_OR_Z
      [
        [ [ c>> not ] [ z>> ] bi or ] keep swap
        [ cog-exec-condition ] [ drop ] if
      ]
    }
    [ drop cog-exec-condition ]
  } case ;

: cog-fetch ( cog -- inst )
  [ pc>> ] keep [ cog-read ] keep PC+ ;

! get status of update z
: cog-isn-z ( cog -- ? )
  isn>> 25 bit? ;

: cog-update-z ( cog -- )
  [ cog-isn-z ] keep swap
  [
    [ alu>> alu-z ] keep swap >>z
  ] when drop ;

: cog-isn-c ( cog -- ? )
  isn>> 24 bit? ;

: cog-update-c ( cog -- )
  [ cog-isn-c ] keep swap
  [
    [ alu>> alu-c ] keep swap >>c
  ] when drop ;

: cog-isn-r ( cog -- ? )
  isn>> 23 bit? ;

: cog-update-r ( cog -- )
  [ cog-isn-r ] keep swap
  [
    [ alu>> alu-result ] keep
    [ cog-dest-address ] keep
    [ cog-write ] keep
  ] when drop ;


: cog-state ( cog -- state )
  state>> ;

: cog-execute? ( cog -- ? )
  cog-state COG_EXECUTE_FETCH = ;

! single step cog to each state
: cog-execute ( cog -- )
  [ state>> ] keep swap
  {
    { COG_INACTIVE [ drop ] }  ! do nothing
    { COG_EXECUTE_FETCH
      [
        [ cog-execute-ins ] keep
        [ cog-fetch ] keep swap >>fisn
        COG_RESULT cog-set-state
      ]
    }
    { COG_RESULT
      [
        [ cog-update-z ] keep
        [ cog-update-c ] keep
        [ cog-update-r ] keep
        [ dup fisn>> swap isn<< ] keep
        COG_FETCH_SOURCE cog-set-state
      ]
    }
    { COG_FETCH_SOURCE
      [
        [ cog-fetch-source ] keep swap >>source
        COG_FETCH_DEST cog-set-state
      ]
    }
    { COG_FETCH_DEST
      [
        [ cog-fetch-dest ] keep swap >>dest
        COG_EXECUTE_FETCH cog-set-state
      ]
    }
    [ drop drop ]
  } case ;

: cog-cycle ( cog -- )
  [ [ cog-execute? ] keep swap ]
  [ [ cog-execute ] keep ]
  do until drop ;

! scamble the code for boot and spin
: cog-scramble ( array -- array )
  [
    ?V{ } clone swap
    [ 14 bit? prefix ] keep   ! 31
    [ 17 bit? prefix ] keep
    [ 3  bit? prefix ] keep
    [ 7  bit? prefix ] keep
    [ 4  bit? prefix ] keep
    [ 1  bit? prefix ] keep
    [ 9  bit? prefix ] keep   ! 25
    [ 2  bit? prefix ] keep
    [ 15 bit? prefix ] keep
    [ 6  bit? prefix ] keep
    [ 29 bit? prefix ] keep
    [ 23 bit? prefix ] keep   ! 20
    [ 26 bit? prefix ] keep
    [ 10 bit? prefix ] keep
    [ 24 bit? prefix ] keep
    [ 13 bit? prefix ] keep
    [ 22 bit? prefix ] keep   ! 15
    [ 18 bit? prefix ] keep
    [ 5  bit? prefix ] keep
    [ 28 bit? prefix ] keep
    [ 20 bit? prefix ] keep
    [ 0  bit? prefix ] keep   ! 10
    [ 11 bit? prefix ] keep
    [ 21 bit? prefix ] keep
    [ 30 bit? prefix ] keep
    [ 27 bit? prefix ] keep
    [ 12 bit? prefix ] keep   ! 5
    [ 25 bit? prefix ] keep
    [ 31 bit? prefix ] keep
    [ 8  bit? prefix ] keep
    [ 16 bit? prefix ] keep
    [ 19 bit? prefix ] keep   ! 0
    drop >bit-array bit-array>integer 32 bits
  ] map ;


! unscamble the code for boot and spin
: cog-unscramble ( array -- array )
  [
    ?V{ } clone swap
    [ 3  bit? prefix ] keep   ! 31
    [ 7  bit? prefix ] keep   ! 30
    [ 21 bit? prefix ] keep   ! 29
    [ 12 bit? prefix ] keep   ! 28
    [ 6  bit? prefix ] keep   ! 27
    [ 19 bit? prefix ] keep   ! 26
    [ 4  bit? prefix ] keep   ! 25
    [ 17 bit? prefix ] keep   ! 24
    [ 20 bit? prefix ] keep   ! 23
    [ 15 bit? prefix ] keep   ! 22
    [ 8  bit? prefix ] keep   ! 21
    [ 11 bit? prefix ] keep   ! 20
    [ 0  bit? prefix ] keep   ! 19
    [ 14 bit? prefix ] keep   ! 18
    [ 30 bit? prefix ] keep   ! 17
    [ 1  bit? prefix ] keep   ! 16
    [ 23 bit? prefix ] keep   ! 15
    [ 31 bit? prefix ] keep   ! 14
    [ 16 bit? prefix ] keep   ! 13
    [ 5  bit? prefix ] keep   ! 12
    [ 9  bit? prefix ] keep   ! 11
    [ 18 bit? prefix ] keep   ! 10
    [ 25 bit? prefix ] keep   ! 9
    [ 2  bit? prefix ] keep   ! 8
    [ 28 bit? prefix ] keep   ! 7
    [ 22 bit? prefix ] keep   ! 6
    [ 13 bit? prefix ] keep   ! 5
    [ 27 bit? prefix ] keep   ! 4
    [ 29 bit? prefix ] keep   ! 3
    [ 24 bit? prefix ] keep   ! 2
    [ 26 bit? prefix ] keep   ! 1
    [ 10 bit? prefix ] keep   ! 0
    drop >bit-array bit-array>integer 32 bits
  ] map ;

! cog copy memory to memory
! turn 2K bytes to 512 longs and store in cog memory
: cog-copy ( barray cog --  )
  swap 4 group
  [ le>  ] map
  INST_SIZE head cog-unscramble swap
  memory>>
  [ write ] 2each
;


! wait for hub routine
: cog-hub ( cog -- cog )
  ;

! memory display
! builds up an an array of strings
: mdw ( n address cog -- str/f )
  [ dup f = ] dip swap
  [ drop drop drop f ]
  [
    [ cog-read-array ] 2keep drop  [ dup f = ] dip swap
    [
      [ drop ] dip
    ]
    [
      >hex 3 CHAR: 0 pad-head >upper ": " append "0x" prepend swap
      [ >hex 8 CHAR: 0 pad-head >upper " " append "0x" prepend ] { } map-as concat append
    ] if
  ] if ;


! create a cog and state is inactive
: <cog> ( -- cog )
  cog new
  cog-setup >>memory
  <alu> >>alu
  [ cog-sfr ] keep
  [ cog-reset ] keep
  <cogdasm> >>mneu
  V{ } clone >>bp ;
