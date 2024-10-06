! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING:  accessors arrays assocs kernel sequences models vectors
        namespaces endian
        parallax.propeller.cogs.cog.par
        parallax.propeller.cogs.cog.cnt
        parallax.propeller.cogs.cog.frqx
        parallax.propeller.cogs.cog.phsx
        parallax.propeller.cogs.cog.vcfgx
        parallax.propeller.cogs.cog.vsclx
        parallax.propeller.cogs.cog.ctrx
        parallax.propeller.cogs.cog.andx
        parallax.propeller.orx

 

       math math.bitwise math.parser alien.syntax combinators
       ! io.binary
       grouping bit-arrays bit-vectors
       parallax.propeller.cogs.alu tools.continuations
       ! parallax.propeller.cogs.cogdisasm
       ascii
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

CONSTANT: PAR_ADDRESS 496   ! 0x1f0
CONSTANT: CNT_ADDRESS 497   ! 0x1f1
CONSTANT: INA_ADDRESS 498   ! 0x1f2
CONSTANT: INB_ADDRESS 499   ! 0x1f3
CONSTANT: OUTA_ADDRESS 500  ! 0x1f4
CONSTANT: OUTB_ADDRESS 501  ! 0x1f5
CONSTANT: DDRA_ADDRESS 502  ! 0x1f6
CONSTANT: DDRB_ADDRESS 503  ! 0x1f7
CONSTANT: CTRA_ADDRESS 504  ! 0x1f8
CONSTANT: CTRB_ADDRESS 505  ! 0x1f9
CONSTANT: FRQA_ADDRESS 506  ! 0x1fa
CONSTANT: FRQB_ADDRESS 507  ! 0x1fb
CONSTANT: PHSA_ADDRESS 508  ! 0x1fc
CONSTANT: PHSB_ADDRESS 509  ! 0x1fd
CONSTANT: VCFG_ADDRESS 510  ! 0x1fe
CONSTANT: VSCL_ADDRESS 511  ! 0x1ff

! tuple to hold cog stuff

TUPLE: cog n pc pcold alu z c memory state isn fisn
    source dest result bp wstate gateone gatetwo
    gatethree gatefour labels hashmneu ! porta portb
    oraio orbio andaio andbio oraout orbout
    orddra orddrb ;



! 32 bit hex string of value "HHHHHHHH" upper case
: >hex-pad8 ( value -- string )
    >hex 8 CHAR: 0 pad-head >upper ;

! 12 bit hex string    
: >hex-pad3 ( d -- $ )
  >hex 3 CHAR: 0 pad-head >upper ;

! 8 bit hex string
: >hex-pad2 ( d -- $ )
  >hex 2 CHAR: 0 pad-head >upper ;


: read-memory-model ( address cog -- model )
    [ 9 bits ] dip      ! we only focus on 9 bit
    memory>> nth ;      ! get the model

! get the cogs ina model
: cog-ina-model ( cog -- model )
    [ INA_ADDRESS ] dip read-memory-model ;

! get the cogs ina model
: cog-inb-model ( cog -- model )
    [ INB_ADDRESS ] dip read-memory-model ;

! get the cog outa model
: outa-model ( cog -- model )
    [ OUTA_ADDRESS ] dip read-memory-model ;

! add an observer for outa
: outa-add-connection ( observer cog -- )
    outa-model add-connection ;

! get the cog outb model
: outb-model ( cog -- model )
    [ OUTB_ADDRESS ] dip read-memory-model ;

! add an observer to outb
: outb-add-connection ( observer cog -- )
    outb-model add-connection ;

! get the cog ddra model
: ddra-model ( cog -- model )
    [ DDRA_ADDRESS ] dip read-memory-model ;

! add an observer for ddra
: ddra-add-connection ( observer cog -- )
    ddra-model add-connection ;

! get the cog ddrb model
: ddrb-model ( cog -- model )
    [ DDRB_ADDRESS ] dip read-memory-model ;

! add an observer to ddrb
: ddrb-add-connection ( observer cog -- )
    ddrb-model add-connection ;


! get the cog vscl model from memory
: vscl-model ( cog -- model )
    [ VSCL_ADDRESS ] dip read-memory-model ;

! add an observer to vscl cog memory
: vscl-add-connection ( observer cog -- )
    vscl-model add-connection ;

! get the cog vcfg model from memory
: vcfg-model ( cog -- model )
    [ VCFG_ADDRESS ] dip read-memory-model ;

! add an observer to vcfg cog memory
: vcfg-add-connection ( observer cog -- )
    vcfg-model add-connection ;

! get the cog ctra model from memory
: ctra-model ( cog -- model )
    [ CTRA_ADDRESS ] dip read-memory-model ;

! add an observer to ctra cog memory
: ctra-add-connection ( observer cog -- )
    ctra-model add-connection ;

! get the cog ctrb model from memory
: ctrb-model ( cog -- model )
    [ CTRB_ADDRESS ] dip read-memory-model ;

! add an observer to ctrb cog memory
: ctrb-add-connection ( observer cog -- )
    ctrb-model add-connection ;


! get the cog frqa model from memory
: frqa-model ( cog -- model )
    [ FRQA_ADDRESS ] dip read-memory-model ;

! add an observer to frqa cog memory
: frqa-add-connection ( observer cog -- )
    frqa-model add-connection ;

! get the cog frqb model from memory
: frqb-model ( cog -- model )
    [ FRQB_ADDRESS ] dip read-memory-model ;

! add an observer to frqb cog memory
: frqb-add-connection ( observer cog -- )
    frqb-model add-connection ;

! get the cog phsa model from memory
: phsa-model ( cog -- model )
    [ PHSA_ADDRESS ] dip read-memory-model ;

! add an observer to phsa cog memory
: phsa-add-connection ( observer cog -- )
    phsa-model add-connection ;

! get the cog phsb model from memory
: phsb-model ( cog -- model )
    [ PHSB_ADDRESS ] dip read-memory-model ;

! add an observer to phsb cog memory
: phsb-add-connection ( observer cog -- )
    phsb-model add-connection ;



! Build the cog memory
: cog-mem-setup ( -- vector )
  MEMORY_SIZE f <array>
  [
    drop 0 <model> 
  ] map >vector
;

! lets get the memory model from memory array
: cog-get-memory ( address cog -- memory )
    memory>> nth ;


 
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


: read-memory-value ( address cog -- d )
    read-memory-model model-value 32 bits ;

: cog-read-array ( n address cog -- array )
  [ f <array> ] 2dip rot
  [
    drop
    [ read-memory-value ] 2keep [ 1 + ] dip rot
  ] map [ drop drop ] dip ;

: write-memory-value ( value address cog -- )
  ! break
    read-memory-model set-model ;

! make cog active
: cog-active ( cog -- )
  COG_EXECUTE_FETCH >>state drop ;

: cog-set-state ( state cog -- )
  swap state<< ;

! return the status if the immediate flag
: cog-isn-i ( cog -- ? )
  isn>> 22 bit? ;

: isn-source-address ( isn -- address )
    8 0 bit-range ;

! get isn destination address
: isn-destination-address ( isn -- address )
    17 9 bit-range ;

: cog-source-address ( cog -- address )
  isn>> isn-source-address ;

: source-value ( isn cog -- value )
    [ isn-source-address ] dip read-memory-value ;

: destination-value ( isn cog -- address )
    [ isn-destination-address ] dip read-memory-value ;


: cog-source-value ( cog -- value )
  [ cog-source-address ] keep read-memory-value ;

: cog-fetch-source ( cog -- source )
  [ cog-isn-i ] keep swap
  [ cog-source-address ] ! immeadiate
  [ cog-source-value ] if ;


! get isn destination address
: cog-dest-address ( cog -- address )
  isn>> isn-destination-address ;

: cog-dest-value ( cog -- value )
  [ cog-dest-address ] keep read-memory-value ;


: cog-fetch-dest ( cog -- value )
  [ cog-dest-address ] keep read-memory-value ;

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
  [ pc>> ] keep [ read-memory-value ] keep PC+ ;

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
    [ write-memory-value ] keep
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
  [ set-model ] 2each
;


! return string value z
: z-string ( ? -- str )
  [ "Z" ] [ "z" ] if ;

! return string vale c
: c-string ( ? -- str )
  [ "C" ] [ "c" ] if ;

! build up a string that indicate
! cogs flag codition
: cog-flag-condition ( cog -- str/f )
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
    read-memory-value >hex-pad8 ;

: cog-isn ( cog -- isn )
    isn>> ;

! get the current opcode from ISN
: opcode ( isn -- op )
    31 26 bit-range ;

! : flags-exstract ( code -- flags )
!  25 22 bit-range ;

! : cond-exstract ( code -- cond )
!  21 18 bit-range ;

! imediate flag
: flag-imd ( cog -- ? )
    22 bit? ;

! flags display
: flag-imd-string ( isn -- $ )
    flag-imd [ "<#>" ] [ " " ] if ;

! read or write flag
: flag-r ( isn -- ? )
    23 bit? ;

! string r flag
: flag-r-string ( isn --  $ )
    flag-r [ "WR" ] [ " " ] if ;

! carry flag
: flag-c ( isn -- ? )
    24 bit? ;

! string of carry
: flag-c-string ( isn -- $ )
    flag-c [ "WC" ] [ " " ] if ;

! z flag
: flag-z ( isn -- ? )
    25 bit? ;

: flag-z-string ( isn -- $ )
    flag-z [ "WZ" ] [ " " ] if ;


: cog-flags-string ( cog -- $ )
    cog-isn
    [ "flags{ " ] dip
    [ flag-z-string " " append ] keep [ append ] dip
    [ flag-c-string " " append ] keep [ append ] dip
    [ flag-r-string " " append ] keep [ append ] dip
    flag-imd-string " " append append "} " append ;


! get the condition of the instruction 
: cog-conditions ( cog -- cond )
  cog-isn 21 18 bit-range ;


! test for nop condition
: cog-condition-string ( cog -- $/f )
  cog-conditions
  H{
    { 0 "NEVER" } { 1 "IF_NC_AND_NZ" } { 2 "IF_NC_AND_Z" }
    { 3 "IF_NC" } { 4 "IF_C_AND_NZ" } { 5 "IF_NZ" }
    { 6 "IF_C_NE_Z" } { 7 "IF_NC_OR_NZ" } { 8 "IF_C_AND_Z" }
    { 9 "IF_C_EQ_Z" } { 10 "IF_Z" } { 11 "IF_NC_OR_Z" }
    { 12 "IF_C" } { 13 "IF_C_OR_NZ" } { 14 "IF_C_OR_Z" }
    { 15 "ALLWAYS" }
  } at ;



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




: code-sub-test ( code -- $/? )
    [ flag-r ] [ cog-isn opcode ] bi swap
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

: cog-subcode ( cog -- $/? )
    cog-isn opcode  ! code
    dup         ! code code
    0 =         ! code ?
    [
        drop    ! 
        "NOP"   ! string
    ]
    [
        ! code
        [ code-sub-test ] keep  ! string code
        swap                    ! code string
        [ drop "ERROR" ] unless
    ] if
  ;



! find out if the current address has a label
: cog-mnuemonic-string ( cog -- $/? )
    [ cog-isn opcode ] keep      ! code cog
    [ hashmneu>> ] keep ! code hash cog
    [ at ] dip          ! ? cog
    swap                ! cog ?
    [
        break
        [ cog-subcode ] keep       ! string cog
        swap                        ! cog string
    ] unless*
    [ drop ] dip
;




! generate a string of source this includes labels
: source-string ( n cog -- string/? )
    [ isn-source-address ] dip ! address cog
    [ cog-label-string ] 2keep ! label address cog 
    rot ! address cog label
    dup ! address cog label label
    [
        ! address cog label
        [
            drop    ! address
            drop
            !  >hex-pad3 "0x" prepend ! hex-string
            ! " " append
        ] dip   ! hex label
        ! append 
    ]
    [
        ! address cog f
        drop    ! address cog
        drop    ! address
        >hex-pad3 "0x" prepend ! hex-string
    ] if    ! string
;

! get the condition of the instruction 
: isn-conditions ( isn -- cond )
  21 18 bit-range ;


! test for nop condition
: condition-string ( isn -- string/f )
  isn-conditions
  H{
    { 0 "NEVER" } { 1 "IF_NC_AND_NZ" } { 2 "IF_NC_AND_Z" }
    { 3 "IF_NC" } { 4 "IF_C_AND_NZ" } { 5 "IF_NZ" }
    { 6 "IF_C_NE_Z" } { 7 "IF_NC_OR_NZ" } { 8 "IF_C_AND_Z" }
    { 9 "IF_C_EQ_Z" } { 10 "IF_Z" } { 11 "IF_NC_OR_Z" }
    { 12 "IF_C" } { 13 "IF_C_OR_NZ" } { 14 "IF_C_OR_Z" }
    { 15 "ALLWAYS" }
  } at ;



! gererate a string of destination including labels
: destination-string ( n cog -- string/? )
    [ isn-destination-address ] dip    ! address cog
    [ cog-label-string ] 2keep  ! label address cog 
    rot ! address cog label
    dup ! address cog label label
    [
        ! address cog label
        [
            drop    ! adddress
            drop
        ] dip
    ]
    [
        ! address cog f
        drop    ! address cog
        drop    ! address
        >hex-pad3 "0x" prepend ! hex-string
    ] if    ! string
;

: flags-string ( isn -- $ )
  [ "flags{ " ] dip
  [ flag-z-string " " append ] keep [ append ] dip
  [ flag-c-string " " append ] keep [ append ] dip
  [ flag-r-string " " append ] keep [ append ] dip
  flag-imd-string " " append append "} " append ;

! find out if the current address has a label
: mnuemonic-string ( isn cog -- $/? )
    [ opcode ] dip      ! opcode cog
    [ hashmneu>> at ] keep ! code hash cog
!    [ at ] dip          ! ? cog
    swap                ! cog ?
    [
        break
        [ cog-subcode ] keep       ! string cog
        swap                        ! cog string
    ] unless*
    [ drop ] dip
;


! Display disasembled code
: cog-list ( address cog --  str/f )
  dup cog? not      ! address cog ? make sure we are looking at cog
  [ drop drop f ]   ! drop everyting and indicate fail
  [
    [ cog-number$ swap cog-address$ append ] 2keep       ! string address cog
    [ cog-address-value$ "0x" prepend " " append append ] 2keep  ! string address cog
    [ read-memory-value ] keep                          ! string value cog
    [ source-string " " append append ] 2keep           ! string cog
    [ destination-string " " append append ] 2keep      ! string cog
    [ swap drop cog-flag-condition " " append append ] 2keep
    [ drop condition-string " " append append ] 2keep                ! string cog
    [ drop flags-string append ] 2keep                    ! string cog
    [ mnuemonic-string append ] 2keep                ! sting cog 
    drop drop
  ] if ;

: cog-list-pc ( cog -- str/f )
  [ pcold>> ] keep cog-list ;


! Need to execute the cog to an address
: cog-execute-address ( address cog -- )
    break
    [ [ pcold>> = ] 2keep rot ]
    [ [ cog-execute-cycle ] keep ] until drop drop ;


: cog-default-labels ( -- hash )
  H{
    { 496 "PAR" }  { 497 "CNT" }  { 498 "INA" }  { 499 "INB" }
    { 500 "OUTA" } { 501 "OUTB" } { 502 "DIRA" } { 503 "DIRB" }
    { 504 "CTRA" } { 505 "CTRB" } { 506 "FRQA" } { 507 "FRQB" }
    { 508 "PHSA" } { 509 "PHSB" } { 510 "VCFG" } { 511 "VSCL" }
  } ;

! get the value from source and destination of the current isn
: get-src-dst ( address cog -- hex )
    [ read-memory-value ] keep ! value cog
    [ drop isn-source-address >hex-pad3 ] 2keep ! hex value cog
    [ " " append ] 2dip ! hex value cog
    [ source-value >hex-pad8 append ] 2keep ! "xxx xxxxxxxx" value cog
    [ "  " append ] 2dip ! "xxx xxxxxxxx  " value cog
    [ drop isn-destination-address >hex-pad3 ] 2keep ! "xxx xxxxxxxx  xxx" value cog
    [ append ] 2dip
    [ " " append ] 2dip ! "xxx xxxxxxxx  xxx " value cog
    destination-value >hex-pad8 append 
;


: pc-src-dst ( cog -- str/f )
    [ pcold>> ] keep get-src-dst ;

! create a cog and state is inactive
: new-cog ( n cog -- cog' )
    new swap >>n        ! allocate memory save the number of cog
    cog-mem-setup >>memory  ! initialise memory componnet
    <alu> >>alu               ! alu is a seperate class
    0 <orx> >>oraio          ! OR the Outputs
    0 <orx> >>orbio
    0 <orx> >>oraout         ! this is used to or the previous cog out with this one
    0 <andx> >>andaio        ! mainly ors the ddr with orio
    0 <andx> >>andbio
    0 <orx> >>orddra         ! or all previous cog ddr with this ddr
    0 <orx> >>orddrb
    [ cog-reset ] keep  ! cog is in reset state
    cog-mnuemonic >>hashmneu
    COG_HUB_GO >>wstate ! need to know if the cog is waiting for hub
    V{ } clone >>bp     ! break points
    cog-default-labels >>labels
    [ [ oraio>> ] keep outa-add-connection ] keep    ! make orio observer of outa memory
    [ [ orbio>> ] keep outb-add-connection ] keep    ! make orio observer of outb memory
    [ [ andaio>> andx-anda ] keep ddra-add-connection ] keep   ! make andio the obsever of ddra memory
    [ [ andbio>> andx-anda ] keep ddrb-add-connection ] keep   ! make andio the obsever of ddrb memory
    [ [ orddra>> ] keep ddra-add-connection ] keep   ! make orddr the obsever of ddr memory
    [ [ orddrb>> ] keep ddrb-add-connection ] keep
    [ [ 0 <vcfgx> ] dip vcfg-add-connection ] keep 
    [ [ 0 <vsclx> ] dip vscl-add-connection ] keep
    [ [ 0 <ctrx> ] dip ctra-add-connection ] keep
    [ [ 0 <ctrx> ] dip ctrb-add-connection ] keep
    [ [ 0 <frqx> ] dip frqa-add-connection ] keep
    [ [ 0 <frqx> ] dip frqb-add-connection ] keep
    [ [ 0 <phsx> ] dip phsa-add-connection ] keep
    [ [ 0 <phsx> ] dip phsb-add-connection ] keep
    [ [ andaio>> ] [ oraio>> ] bi add-connection ] keep   ! andio is the obsever of orio
    [ [ andbio>> ] [ orbio>> ] bi add-connection ] keep
    [ [ oraout>> ] [ andaio>> ] bi add-connection ] keep ! orout is the obsever of andio
;

! create a cog and state is inactive
: <cog> ( n -- cog )
    cog new-cog ! create the cog class
;

