! Wraper for cog
! to display memory and registers

USING: accessors arrays kernel parallax.propeller.cogs.cog math
        sequences tools.continuations ;


IN: parallax.propeller.cogs

CONSTANT: COGNUMBER 8

TUPLE: cogs cog-array num-longs ;


! create an instance of 8 cogs
: cogs-array ( -- array )
  COGNUMBER f <array>
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



: cogs-mdl ( n cogn address cogs -- $array )
  [ [ swap ] dip cog-array>> nth ] keep num-longs>> -roll
  rot f <array>
  [
    break
    drop
    [ cog-mdl ] 3keep [ 4 + ] dip roll
  ] map 3nip ;


: cogs-boot ( array cogs -- )
  cog-array>> first [ cog-copy ] keep cog-active ;

: <cogs> ( -- cogs )
  cogs new
  cogs-array >>cog-array
  4 >>num-longs ! this is the defult number of data longs to display
  ;
