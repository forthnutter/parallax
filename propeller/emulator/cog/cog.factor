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
       math alien.syntax combinators
;

IN: parallax.propeller.emulator.cog




TUPLE: cog pc z c memory state isna isnb sorce dest result ;

CONSTANT: COG_INACTIVE                  0
CONSTANT: COG_EXECUTE_B_FETCH_A         1
CONSTANT: COG_RESULT_B                  2
CONSTANT: COG_FETCH_SOURCE_A            3
CONSTANT: COG_FETCH_DEST_A              4
CONSTANT: COG_EXCUTE_A_FETCH_B          5
CONSTANT: COG_RESULT_A                  6

CONSTANT: COG_START_ISN                 0


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
  0 >>pc COG_START_ISN >>isna COG_START_ISN >>isnb
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

: cog-execute-b ( cog -- )
  

: cog-execute ( cog -- )
  [ state>> ] keep swap
  {
    { COG_INACTIVE [ drop ] }  ! do nothing
    { COG_EXECUTE_B_FETCH_A [ drop ] }
    { COG_RESULT_B [ drop ] }
    { COG_FETCH_SOURCE_A [ drop ] }
    { COG_FETCH_DEST_A [ drop ] }
    { COG_EXCUTE_A_FETCH_B [ drop ] }
    { COG_RESULT_A [ drop ] }
    [ drop drop ]
  } case ;


! create a cog and state is inactive
: <cog> ( -- cog )
  cog new
  cog-setup >>memory
  [ cog-sfr ] keep
  [ cog-reset ] keep ;
