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
       math math.bitwise alien.syntax combinators io.binary
       grouping intel.hex
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

! tuple to hold cog stuff
TUPLE: cog pc z c memory state isn fisn sorce dest result bus ;


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

: cog-write ( value address cog -- )
  cog-memory write ;

! make cog active
: cog-active ( cog -- )
  COG_EXECUTE_FETCH >>state drop ;

: cog-set-state ( state cog -- )
  swap state<< ;


! extrac the conditional code
: isn-cond ( isn -- cond )
  21 18 bit-range ;

: cog-state-z ( cog -- ? )
  z>> ;

: cog-state-nz ( cog -- ? )
  z>> not ;


: cog-execute-ins ( cog -- )
  [ isn>> isn-cond ] keep swap
  {
    { NEVER [ drop ] } ! yes do nothing
    { IF_NC_AND_NZ
      [
        cog-state-nz
      ]
    }
    { IF_NC_AND_Z [ drop ] }
    { IF_NC [ drop ] }
    { IF_C_AND_NZ [ drop ] }
    { IF_NZ [ drop ] }
    { IF_C_NE_Z [ drop ] }
    { IF_NC_OR_NZ [ drop ] }
    { IF_C_AND_Z [ drop ] }
    { IF_C_EQ_Z [ drop ] }
    { IF_Z [ drop ] }
    { IF_NC_OR_Z [ drop ] }
    [ drop drop ]
  } case ;

: cog-fetch ( cog -- inst )
  [ pc>> ] keep
  [ cog-read ] keep
  PC+
  ;

: cog-execute ( cog -- )
  [ state>> ] keep swap
  {
    { COG_INACTIVE [ drop ] }  ! do nothing
    { COG_EXECUTE_FETCH
      [
        [ cog-execute-ins ] keep
        [ cog-fetch ] keep swap >>isn
        COG_RESULT cog-set-state
      ]
    }
    { COG_RESULT
      [
        [ dup fisn>> swap isn<< ] keep 
        COG_FETCH_SOURCE cog-set-state
      ]
    }
    { COG_FETCH_SOURCE [ COG_FETCH_DEST cog-set-state ] }
    { COG_FETCH_DEST [ COG_EXECUTE_FETCH cog-set-state ] }
    [ drop drop ]
  } case ;

! cog copy memory to memory
! turn 2K bytes to 512 longs and store in cog memory
: cog-copy ( barray cog --  )
  swap 4 group
  [ le>  ] map
  INST_SIZE head swap
  memory>>
  [ write ] 2each
;


! wait for hub routine
: cog-hub ( cog -- cog )
  ;


! create a cog and state is inactive
: <cog> ( -- cog )
  cog new
  cog-setup >>memory
  [ cog-sfr ] keep
  [ cog-reset ] keep ;
