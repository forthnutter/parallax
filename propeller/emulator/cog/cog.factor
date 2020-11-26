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
       math
;

IN: parallax.propeller.emulator.cog




TUPLE: cog pc memory ;




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
!  0 <cnt>  497 0 <cog-memory> add-cog-memory swap push dup ! System counter
!  0 <ina>  498 0 <cog-memory> add-cog-memory swap push dup ! Port A input
!  0 <inb>  499 0 <cog-memory> add-cog-memory swap push dup ! Port B input
!  0 <outa> 500 0 <cog-memory> add-cog-memory swap push dup ! Port A out
!  0 <outb> 501 0 <cog-memory> add-cog-memory swap push dup ! Port B out
!  0 <dira> 502 0 <cog-memory> add-cog-memory swap push dup ! Port A Direction
!  0 <dirb> 503 0 <cog-memory> add-cog-memory swap push dup ! Port B Direction
!  0 <ctr>  504 0 <cog-memory> add-cog-memory swap push dup ! Counter A control
!  0 <ctr>  505 0 <cog-memory> add-cog-memory swap push dup ! Counter B control
!  0 <frqa> 506 0 <cog-memory> add-cog-memory swap push dup ! Counter A freq
!  0 <frqb> 507 0 <cog-memory> add-cog-memory swap push dup ! Counter B freq
!  0 <phsa> 508 0 <cog-memory> add-cog-memory swap push dup ! Counter A phase
!  0 <phsb> 509 0 <cog-memory> add-cog-memory swap push dup ! Counter B phase
!  0 <vcfg> 510 0 <cog-memory> add-cog-memory swap push dup ! Video Configuration
!  0 <vscl> 511 0 <cog-memory> add-cog-memory swap push     ! Video Scale
drop drop ;

: cog-reset ( cog -- cog )
    0 >>pc
;


: <cog> ( -- cog )
   cog new
   cog-setup >>memory
   dup cog-sfr
   cog-reset
;

: cog-read ( address cog -- d )
    cog-memory read ;

: cog-write ( value address cog -- )
   cog-memory write ;


! increment PC
: PC+ ( cog -- ) [ pc>> 1 + ] keep pc<< ;


! decrement PC
: PC- ( cog -- ) [ pc>> 1 - ] keep pc<< ;
