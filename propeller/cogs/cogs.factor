! Wraper for cog
! to display memory and registers

USING: accessors arrays ascii kernel parallax.propeller.cogs.cog
      math math.parser parallax.propeller.inx parallax.propeller.ddrx
      sequences tools.continuations vectors ;


IN: parallax.propeller.cogs

CONSTANT: COGNUMBEROF 8
CONSTANT: INA_ADDRESS 498
CONSTANT: INB_ADDRESS 499
CONSTANT: OUTA_ADDRESS 500
CONSTANT: OUTB_ADDRESS 501
CONSTANT: DDRA_ADDRESS 502
CONSTANT: DDRB_ADDRESS 503




TUPLE: cogs cog-array num-longs ina inb ddra ddrb ;


! create an instance of 8 cogs
: cogs-array ( -- array )
  COGNUMBEROF f <array>
  [
    swap drop
    <cog>
  ] map-index ;

! go through all cogs and
! do a complete step to the next instrcution
: cogs-step-cycle ( cogs -- )
  cog-array>>
  [
    cog-execute-cycle
  ] each ;

! do a clock step of the instrction
: cogs-step-clock ( cogs -- )
  cog-array>>
  [
    cog-execute
  ] each ;

! Add to each cog the object dependency
: cogs-add-dependency ( object address cogs -- )
  cog-array>>
  [
    [ 2dup ] dip
    cog-mem-dependency
  ] each 2drop ;

: cogs-set-dependency ( cogs -- )
  [  
  [ [ ina>> INA_ADDRESS ] keep cogs-add-dependency ]
  [ [ inb>> INB_ADDRESS ] keep cogs-add-dependency ]
  bi ] keep
  [ [ ddra>> DDRA_ADDRESS ] keep cogs-add-dependency ]
  [ [ ddrb>> DDRB_ADDRESS ] keep cogs-add-dependency ]
  bi ;

! go through all cogs and activate all memory dependecies
: cogs-activate ( cogs -- )
  cog-array>>
  [
    cog-activate
  ] each ;

! cog display memory
: cogs-mdl ( n cogn address cogs -- $array )
  [ [ swap ] dip cog-array>> nth ] keep num-longs>> -roll
  rot f <array>
  [
    drop [ cog-mdl ] 3keep [ 4 + ] dip roll
  ] map 3nip ;

! cog display disasembler
: cogs-list ( n cogn address cogs -- $array )
  [ swap ] dip cog-array>> nth
  rot f <array>
  [
    drop [ cog-list ] 2keep [ 1 + ] dip rot
  ] map 2nip ;

! get the pc address of each cog string the mnuemonic into list
: cogs-list-pc ( cogs -- $array )
  COGNUMBEROF <vector>      ! the array to send back
  swap cog-array>>          ! swap to get cogs back now get cog array
  [
    cog-list-pc swap [ push ] keep
  ] each ;

! get all actve list pc instructions for each cog
: cogs-alist-pc ( cogs -- $array )
  COGNUMBEROF <vector>      ! make an array for return
  swap cog-array>>          ! get the array of cogs
  [
    [ cog-active? ] keep swap
    [ cog-list-pc swap [ push ] keep ]
    [ drop ] if
  ] each ; 

: cogs-boot ( array cogs -- )
  cog-array>> first [ cog-copy ] keep cog-active ;


! read INA value and return string
: cogs-ina-read ( cogs -- $array )
  1 <vector> swap   ! cogs first
  ina>> read >hex 8 CHAR: 0 pad-head >upper
  "$" prepend swap 
  [ push ] keep ;


: <cogs> ( -- cogs )
  break
  cogs new
  0 <inx> >>ina     ! INA is a global input
  0 <inx> >>inb     ! same for INB 
  0 <ddrx> >>ddra   ! all cogs have the same 
  0 <ddrx> >>ddrb
  cogs-array >>cog-array
  4 >>num-longs ! this is the defult number of data longs to display
  [ cogs-set-dependency ] keep
  [ cogs-activate ] keep
  ;
