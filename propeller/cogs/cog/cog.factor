! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors
        namespaces
       parallax.propeller.cogs.cog.memory
       parallax.propeller.cogs.cog.par
       parallax.propeller.cogs.cog.cnt
       parallax.propeller.inx
       parallax.propeller.cogs.cog.out
       parallax.propeller.cogs.cog.dir
       parallax.propeller.cogs.cog.ctr
       parallax.propeller.cogs.cog.frq
       parallax.propeller.cogs.cog.phs
       parallax.propeller.cogs.cog.vcfg
       parallax.propeller.cogs.cog.vscl
       math math.bitwise math.parser alien.syntax combinators
       io.binary grouping bit-arrays bit-vectors
       parallax.propeller.cogs.alu tools.continuations
       parallax.propeller.cogs.cogdisasm ascii
;

IN: parallax.propeller.cogs.cog

! Constants
CONSTANT: COG_INACTIVE                  0
CONSTANT: COG_EXECUTE_FETCH             1
CONSTANT: COG_RESULT                    2
CONSTANT: COG_FETCH_SOURCE              3
CONSTANT: COG_FETCH_DEST                4

CONSTANT: COG_HUB_GO                    0
CONSTANT: COG_HUB_WAIT                  1

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

CONSTANT: MEMORY_SIZE 512
CONSTANT: INST_SIZE   496
CONSTANT: SPR_SIZE    16

! tuple to hold cog stuff

TUPLE: cog n pc pcold alu z c memory state isn fisn source dest result bp mneu wstate ;


: cog-memory ( address cog -- memory )
   memory>> nth ;

: cog-memory-select ( address -- mem/sfr )
  {
    { 496 [ 0 <par> ] }   ! $01f0 boot parameter
    { 497 [ 0 <cnt> ] }   ! $01f1 system counter
    { 498 [ inag get ] }   ! $01f2 Port A input
    { 499 [ 0 <inx> ] }   ! $01f3 Port B input
    { 500 [ 0 <out> ] }   ! $01f4 Port A output
    { 501 [ 0 <out> ] }   ! $01f5 Port B output
    { 502 [ 0 <dir> ] }   ! $01f6 Port A Direction
    { 503 [ 0 <dir> ] }   ! $01f7 Port B Direction
    { 504 [ 0 <ctr> ] }   ! $01f8 Counter A control
    { 505 [ 0 <ctr> ] }   ! $01f9 Counter B control
    { 506 [ 0 <frq> ] }   ! $01fa Counter A Frequency
    { 507 [ 0 <frq> ] }   ! $01fb Counter B Frequency
    { 508 [ 0 <phs> ] }   ! $01fc Counter A phase
    { 509 [ 0 <phs> ] }   ! $01fd Counter B phase
    { 510 [ 0 <vcfg> ] }  ! $01fe Video Configuration
    { 511 [ 0 <vscl> ] }  ! $01ff Video Scale
    [ drop 0 <memory> ]   ! default general memory function
  } case ;

: cog-setup ( -- vector )
   MEMORY_SIZE f <array>
   [
      [ drop ] dip cog-memory-select
   ] map-index >vector ;

: cog-mem-setup ( -- vector )
  MEMORY_SIZE f <array>
  [
    drop 0 <memory> 
  ] map >vector
  [ 500 swap nth 0 <out> swap add-memory-write ] keep   ! out A
  [ 502 swap nth 0 <dir> swap add-memory-write ] keep   ! dir A

 ;


: cog-reset ( cog -- )
  0 >>pc 0 >>pcold COG_START_ISN >>isn
  COG_INACTIVE >>state
  drop ;

! increment PC
: PC+ ( cog -- )
  [ [ pc>> ] [ pcold<< ] bi ] keep
  [ pc>> 1 + ] keep pc<< ;


! decrement PC
: PC- ( cog -- )
  [ [ pc>> ] [ pcold<< ] bi ] keep
  [ pc>> 1 - ] keep pc<< ;

! set the PC in special way
: PC< ( d cog -- )
  [ pc<< ] [ pcold<< ] 2bi ;


: cog-read ( address cog -- d )
  cog-memory memory-read ;

: cog-read-array ( n address cog -- array )
  [ f <array> ] 2dip rot
  [
    drop
    [ cog-read ] 2keep [ 1 + ] dip rot
  ] map [ drop drop ] dip ;

: cog-write ( value address cog -- )
  ! break
  cog-memory memory-write ;

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

! multi function jump can return 
: cog-jump ( cog -- )
  [ dest>> 0b111111111 unmask ] keep
  [ pc>> bitor 0 ] keep
  [ alu>> alu-add drop ] keep
  [ source>> ] keep PC< ;

! instruction to move source to destination
: cog-mov ( cog -- )
  [ [ dest>> ] [ source>> ] bi ] keep
  alu>> alu-update drop ;

: cog-djnz ( cog -- )
  [ dest>> 1 ] keep
  [ alu>> alu-sub ] keep swap
  alu-z not
  [ [ source>> ] keep PC< ] [ drop ] if ;


: cog-abs ( cog -- )
  [ dest>> ] keep
  [ source>> ] keep
  alu>> alu-abs drop ;


: cog-exec-condition ( cog -- )
  ! break
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


: cog-wstate ( cog -- state )
  wstate>> ;


: cog-execute? ( cog -- ? )
  [ cog-state COG_INACTIVE = ] keep
  [ cog-state COG_EXECUTE_FETCH = ] keep
  [ cog-wstate COG_HUB_WAIT = ] keep
  drop or or ;

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

: cog-execute-cycle ( cog -- )
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
  [ memory-write ] 2each
;


! wait for hub routine
: cog-hub ( cog -- cog )
  ;

! return string value z
: z-string ( ? -- str )
  [ "Z" ] [ "z" ] if ;

! return string vale c
: c-string ( ? -- str )
  [ "C" ] [ "c" ] if ;

! build up a string that indicate
! cogs flag codition
: cog-condition ( cog -- str/f )
  dup cog? not
  [ drop f ]
  [
    [ z>> z-string ] [ c>> c-string ] bi ! get the two cog status
    [ " " append ] dip append 
  ] if ;



! memory display
! builds up an an array of strings
: cog-mdl ( n address cog -- str/f )
  dup cog? not
  [ drop drop drop f ]
  [
    [ n>> ] keep [ number>string "cog-" prepend " " append -rot ] dip
    [ cog-read-array ] 2keep drop  [ dup array? not ] dip swap
    [ drop drop drop f ]
    [
      >hex 3 CHAR: 0 pad-head >upper ": " append "0x" prepend swap
      [ append ] dip
      [
        >hex 8 CHAR: 0 pad-head >upper " " append "0x" prepend
      ] { } map-as concat append
    ] if
  ] if ;

! test to if cog is active
: cog-active? ( cog -- ? )
  cog-state COG_INACTIVE = not ;

! Display disasembled code
: cog-list ( address cog --  str/f )
  dup cog? not  ! make sure we are looking at cog
  [ drop drop f ]    ! drop everyting and indicate fail
  [
    [ n>> ] keep [ number>string "cog-" prepend " " append swap ] dip
    [ 1 ] 2dip ! how many instructions we need
    [ cog-read-array first ] 2keep mneu>> [ swap dup ] dip
    [ >hex 3 CHAR: 0 pad-head >upper ": " append "0x" prepend ] 3dip
    [ append ] 3dip
    [ >hex 8 CHAR: 0 pad-head >upper " " append "0x" prepend ] 2dip
    [ append ] 2dip
    opcode-string append
  ] if ;

: cog-list-pc ( cog -- str/f )
  [ pcold>> ] keep cog-list ;

! create a cog and state is inactive
: new-cog ( n cog -- cog' )
  new swap >>n        ! allocate memory save the number of cog
  cog-mem-setup >>memory  ! initialise memory componnet
  <alu> >>alu         ! alu is a seperate class
  [ cog-reset ] keep  ! cog is in reset state
  <cogdasm> >>mneu
  COG_HUB_GO >>wstate ! need to know if the cog is waiting for hub
  V{ } clone >>bp ;   ! break points

! create a cog and state is inactive
: <cog> ( n -- cog )
  cog new-cog ; ! create the cog class
