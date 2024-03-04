! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays assocs kernel sequences models vectors
        namespaces endian
       parallax.propeller.cogs.cog.memory
       parallax.propeller.cogs.cog.par
       parallax.propeller.cogs.cog.cnt
       parallax.propeller.cogs.cog.frq
       parallax.propeller.cogs.cog.phs
       parallax.propeller.cogs.cog.vscl
       parallax.propeller.orx
       parallax.propeller.outx
       parallax.propeller.andx
       parallax.propeller.ddrx
       parallax.propeller.ctrx
       parallax.propeller.vcfgx
       math math.bitwise math.parser alien.syntax combinators
       ! io.binary
       grouping bit-arrays bit-vectors
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
CONSTANT: CSUB         33   ! 0x21
CONSTANT: CMOV         40   ! 0x28
CONSTANT: CABS         42   ! 0x2A
CONSTANT: CDJNZ        57   ! 0x39

CONSTANT: MEMORY_SIZE 512
CONSTANT: INST_SIZE   496
CONSTANT: SPR_SIZE    16

! tuple to hold cog stuff

TUPLE: cog n pc pcold alu z c memory state isn fisn
    source dest result bp wstate gateone gatetwo
    gatethree gatefour labels hashmneu ;



! 32 bit hex string of value "0xHHHHHHHH" upper case
: >hex-pad8 ( value -- string )
    >hex 8 CHAR: 0 pad-head >upper "0x" prepend ;

: cog-memory ( address cog -- memory )
   memory>> nth ;

: cog-memory-select ( address -- mem/sfr )
  {
    { 496 [ 0 <par> ] }   ! $01f0 boot parameter
    { 497 [ 0 <cnt> ] }   ! $01f1 system counter

    { 506 [ 0 <frq> ] }   ! $01fa Counter A Frequency
    { 507 [ 0 <frq> ] }   ! $01fb Counter B Frequency
    { 508 [ 0 <phs> ] }   ! $01fc Counter A phase
    { 509 [ 0 <phs> ] }   ! $01fd Counter B phase

    { 511 [ 0 <vscl> ] }  ! $01ff Video Scale
    [ drop 0 <memory> ]   ! default general memory function
  } case ;

: cog-setup ( -- vector )
   MEMORY_SIZE f <array>
   [
      [ drop ] dip cog-memory-select
   ] map-index >vector ;



: cog-deactivate ( cog -- )
  memory>>
  [
    memory-deactivate
  ] each ;

! routine to inject a object into dependecy
! may require memory deactivation and then activation
! : memory-set-dependency ( object address memory -- )
!  nth memory-add-dependency ;
: cog-mem-dependency ( dep address cog -- )
  memory>> nth memory-add-dependency ;


: cog-mem-connection ( object address cog -- )
  memory>> nth add-connection ;

! Build the cog memory
: cog-mem-setup ( -- vector )
  MEMORY_SIZE f <array>
  [
    drop 0 <memory> 
  ] map >vector
;

! lets get the memory model from memory array
: cog-get-memory ( address cog -- memory )
    memory>> nth ;


! create and 
! create an Out and then add orx model
: cog-out-set ( cog -- outx )
    [ n>> <outx> ]
    [ gateone>> ]
    bi dupd add-dependency ;


: cog-ctr-set ( cog -- ctrx )
    [ drop 0 <ctrx> ]
    [ gateone>> ]
    bi dupd add-dependency ;


: cog-ddr-set ( cog -- ddrx )
    [
        [ drop 0 <ddrx> ]
        [ gatetwo>> ]
        bi dupd add-dependency
    ] keep
    gatefour>> dupd add-dependency
;


: cog-vcfg-set ( cog -- vcfgx )
    [ drop 0 <vcfgx> ]
    [ gateone>> ]
    bi dupd add-dependency ;



! set up cog dependency for all special functions
: cog-set-dependencies ( cog -- cog )
    [ [ [ 500 ] dip cog-get-memory ] [ cog-out-set ] bi add-dependency ] keep
    [ [ [ 502 ] dip cog-get-memory ] [ cog-ddr-set ] bi add-dependency ] keep
!    [ [ cog-ddr-set 502 ] keep cog-mem-dependency ] keep
!   [ [ cog-ctr-set 503 ] keep cog-mem-dependency ] keep
!   [ [ cog-ctr-set 504 ] keep cog-mem-dependency ] keep
!    [ [ cog-vcfg-set 510 ] keep cog-mem-dependency ] keep
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
  cog-memory read ;

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

: cog-address-value ( address cog -- value )
  cog-read ;

: cog-source-address ( cog -- address )
  isn>> 8 0 bit-range ;


: cog-source-value ( cog -- value )
  [ cog-source-address ] keep cog-read ;

: cog-fetch-source ( cog -- source )
  [ cog-isn-i ] keep swap
  [ cog-source-address ] ! immeadiate
  [ cog-source-value ] if ;


! get isn destination address
: cog-dest-address ( cog -- address )
  isn>> 17 9 bit-range ;

: cog-dest-value ( cog -- value )
  [ cog-dest-address ] keep cog-read ;


: cog-fetch-dest ( cog -- value )
  [ cog-dest-address ] keep cog-read ;

! find out if the current address has a label
: cog-label-string ( address cog -- $/? )
  labels>> at ;

! generate a string of source this includes labels
: cog-source-string ( cog -- string/? )
    dup ! cog cog
    [ cog-source-address ] keep ! cog address cog
    [ cog-label-string ] 2keep ! cog label address cog 
    rot ! cog address cog label
    dup ! cog address cog label label
    [
        ! cog address cog label
        [ drop drop ] dip   ! label
    ]
    [
        ! cog address cog label
        drop    ! cog address cog
        drop    ! cog address
        >hex-pad3 "0x" prepend ! cog hex-string
    ] if    ! cog string
    [ cog-source-value ] dip    ! value string
    [ >hex-pad8 " [0x" prepend "]" append ] dip prepend
;


! generate a string of destination this includes labels
: cog-dest-string ( cog -- string/? )
    dup ! cog cog
    [ cog-dest-address ] keep ! cog address cog
    [ cog-label-string ] 2keep ! cog label address cog 
    rot ! cog address cog label
    dup ! cog address cog label label
    [
        ! cog address cog label
        [ drop drop ] dip   ! label
    ]
    [
        ! cog address cog label
        drop    ! cog address cog
        drop    ! cog address
        >hex-pad3 "0x" prepend ! cog hex-string
    ] if    ! cog string
    [ cog-dest-value ] dip    ! value string
    [ >hex-pad8 " [0x" prepend "]" append ] dip prepend
;


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
    break
  [ dest>> 1 ] keep
  [ alu>> alu-sub ] keep swap
  alu-z not
  [ [ source>> ] keep PC< ] [ drop ] if ;


: cog-abs ( cog -- )
  [ dest>> ] keep
  [ source>> ] keep
  alu>> alu-abs drop ;

: cog-sub ( cog -- )
    [ dest>> ] keep
    [ source>> ] keep
    alu>> alu-sub drop ;

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
    { CSUB [ cog-sub ] }
    { CDJNZ [ cog-djnz ] }
    [ break drop drop ]
  } case
;

: cog-execute-ins ( cog -- )
  [ isn>> isn-cond ] keep swap
  {
    { NEVER [ drop ] } ! yes do nothing
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

! Build a string for cog number
: cog-number$ ( cog -- str )
    n>> number>string "COG-" prepend " " append ;

! Build a string to for an address
: cog-address$ ( address -- str )
    >hex 3 CHAR: 0 pad-head >upper ": " append "0x" prepend ;

: cog-read-address ( address cog -- value )
    [ 1 ] 2dip cog-read-array first ;

! Build a string for th value found at address
: cog-value$ ( value -- str )
    >hex 8 CHAR: 0 pad-head >upper " " append "0x" prepend ;


! string of value from address
: cog-address-value$ ( address cog -- string )
    cog-address-value >hex-pad8 ;


: cog-mnuemonic ( -- hash )
  H{
    { 1 "DWORD" } { 2 "DLONG" }
    { 3 "SYSOP" } { 8 "ROR" }
    { 9 "ROL" } { 10 "SHR" } { 11 "SHL" }
    { 12 "RCR" } { 13 "RCL" } { 14 "SAR" }
    { 15 "REV" } { 16 "MINS" } { 17 "MAXS" }
    { 18 "MIN" } { 19 "MAX" } { 20 "MOVS" }
    { 21 "MOVD" } { 22 "MOVI" } { 23 "JMPRET" }
    { 24 "AND" } { 25 "ANDN" } { 26 "OR" }
    { 27 "XOR" } { 28 "MUXC" } { 29 "MUXNC" }
    { 30 "MUXZ" } { 31 "MUXNZ" } { 32 "ADD" }
    { 33 "SUB" } { 34 "ADDABS" } { 35 "SUBABS" }
    { 36 "SUMC" } { 37 "SUMNC" } { 38 "SUMZ" }
    { 39 "SUMNZ" } { 40 "MOV" } { 41 "NEG" }
    { 42 "ABS" } { 43 "ABSNEG" } { 44 "NEGC" }
    { 45 "NEGNC" } { 46 "NEGZ" } { 47 "NEGNZ" }
    { 48 "CMPS" } { 49 "CMPSX" } { 50 "ADDX" }
    { 51 "SUBX" } { 52 "ADDS" } { 53 "SUBS" }
    { 54 "ADDSX" } { 55 "SUBSX" } { 56 "CMPSUB" }
    { 57 "DJNZ" } { 58 "TJNZ" } { 59 "TJZ" }
    { 60 "WAITPEQ" } { 61 "WAITPNE" } { 62 "WAITCNT" }
    { 63 "WAITVID" }
  } ;


: cog-sub-test ( code -- $/? )
    [ flag-r ] [ opcode-exstract ] bi swap
    [
        H{
            { 0 "RDBYTE" } { 1 "RDWORD" } { 2 "RDLONG" }
            { 23 "JMPRET" } { 24 "AND" } { 33 "SUB" }
        } at
    ]
    [ 
        H{
            { 0 "WRBYTE" } { 1 "WRWORD" } { 2 "WRLONG" }
            { 23 "JMP" } { 24 "TEST" } { 33 "CMP" }
        } at  
    ] if
;

: cog-subcode ( code -- $/? )
    break
    dup 0 = 
    [ drop "NOP" ]
    [ 
        [ cog-sub-test ] keep swap
        [ drop "ERROR" ] unless
    ] if
  ;

: cog-opcode ( cog -- op )
    isn>> 31 26 bit-range ;

! find out if the current address has a label
: cog-mnuemonic-string ( cog -- $/? )
    [ cog-opcode ] keep      ! code cog
    [ hashmneu>> ] keep ! code hash cog
    [ at ] dip          ! ? cog
    [ 
        dup
        [

        ]
        [
            drop                ! isn        
            cog-subcode       ! string
        ] if
    ] dip drop
;



! Display disasembled code
: cog-list ( address cog --  str/f )
  dup cog? not      ! address cog ? make sure we are looking at cog
  [ drop drop f ]   ! drop everyting and indicate fail
  [
    [ cog-number$ swap cog-address$ append ] 2keep       ! string address cog
    [ cog-address-value$ append ] keep                  ! string cog
    [ " " append ] dip                                  ! string cog
    [ cog-source-string append ] keep                   ! string cog
    [ " " append ] dip                                  ! string cog
    [ cog-dest-string append ] keep                     ! string cog
    [ " " append ] dip                                  ! string cog
    [ break cog-mnuemonic-string append ] keep                ! sting cog 
    drop
  ] if ;

: cog-list-pc ( cog -- str/f )
    break
  [ pcold>> ] keep cog-list ;

! or connects to and
: cog-orand ( cog -- cog )
    [ [ gateone>> ] [ gatetwo>> ] bi andx-dependency ] keep ; 

: cog-andor ( cog -- cog )
    [ gatetwo>> ] keep
    [ gatethree>> add-dependency ] keep
;


: cog-gate-activate ( cog -- cog )
    [ gateone>> activate-model ] keep
    [ gatetwo>> activate-model ] keep
    [ gatethree>> activate-model ] keep
    [ gatefour>> activate-model ] keep ;

! this will make all dependency point to memory 
! so the memory will update to dependency changes
: cog-activate ( cog -- )
  memory>>
  [
    memory-activate
  ] each ;

: cog-default-labels ( -- hash )
  H{
    { 496 "PAR" }  { 497 "CNT" }  { 498 "INA" }  { 499 "INB" }
    { 500 "OUTA" } { 501 "OUTB" } { 502 "DIRA" } { 503 "DIRB" }
    { 504 "CTRA" } { 505 "CTRB" } { 506 "FRQA" } { 507 "FRQB" }
    { 508 "PHSA" } { 509 "PHSB" } { 510 "VCFG" } { 511 "VSCL" }
  } ;

! create a cog and state is inactive
: new-cog ( n cog -- cog' )
  new swap >>n        ! allocate memory save the number of cog
  cog-mem-setup >>memory  ! initialise memory componnet
  <alu> >>alu         ! alu is a seperate class
  [ cog-reset ] keep  ! cog is in reset state
  cog-mnuemonic >>hashmneu
  COG_HUB_GO >>wstate ! need to know if the cog is waiting for hub
  V{ } clone >>bp     ! break points
  0 <orx> >>gateone      ! or all the out amd some special function
  0 <andx> >>gatetwo     !
  0 <orx> >>gatethree    ! or out to next cog
  0 <orx> >>gatefour
  cog-orand
  cog-andor
  cog-set-dependencies
  cog-default-labels >>labels
  ! cog-gate-activate
;




! create a cog and state is inactive
: <cog> ( n -- cog )
  cog new-cog ! create the cog class
;
