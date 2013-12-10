! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors parallax.propeller.emulator.cog.memory ;
IN: parallax.propeller.emulator.cog




TUPLE: cog pc memory ;



: mem-setup ( -- vector )
   COG_MEMORY_SIZE f <array> dup
   [
      pick          ! get array
      swap dup      ! index
      0             ! value
      <cog-memory>
      swap          ! index
      pick          ! array
      set-nth
      drop drop
   ] each-index
   >vector dup
   ! special purpose registers
   496 0 <cog-memory> \ PAR swap add-cog-memory swap push dup ! Boot Parameter
   497 0 <cog-memory> \ CNT swap add-cog-memory swap push dup ! System counter
   498 0 <cog-memory> \ INA swap add-cog-memory swap push dup ! Port A input
   499 0 <cog-memory> \ INB swap add-cog-memory swap push dup ! Port B input
   500 0 <cog-memory> \ OUTA swap add-cog-memory swap push dup ! Port A out
   501 0 <cog-memory> \ OUTB swap add-cog-memory swap push dup ! Port B out
   502 0 <cog-memory> \ DIRA swap add-cog-memory swap push dup ! Port A Direction
   503 0 <cog-memory> \ DIRB swap add-cog-memory swap push dup ! Port B Direction
   504 0 <cog-memory> \ CTRA swap add-cog-memory swap push dup ! Counter A control
   505 0 <cog-memory> \ CTRB swap add-cog-memory swap push dup ! Counter B control
   506 0 <cog-memory> \ FRQA swap add-cog-memory swap push dup ! Counter A freq
   507 0 <cog-memory> \ FRQB swap add-cog-memory swap push dup ! Counter B freq
   508 0 <cog-memory> \ PHSA swap add-cog-memory swap push dup ! Counter A phase
   509 0 <cog-memory> \ PHSB swap add-cog-memory swap push dup ! Counter B phase
   510 0 <cog-memory> \ VCFG swap add-cog-memory swap push dup ! Video Configuration
   511 0 <cog-memory> \ VSCL swap add-cog-memory swap push     ! Video Scale
   ;

: cog-reset ( cog -- cog )
    0 >>pc
;



: <cog> ( -- cog )
   cog new mem-setup >>memory cog-reset
;


: cog-read ( address cog -- d )
    memory>> nth read ;

: cog-write ( value address cog -- )
   memory>> dup vector?
   [
      nth dup cog-memory?
      [ ?set-model ] [ drop drop ] if
   ]
   [ drop drop drop ] if
;