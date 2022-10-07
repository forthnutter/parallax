! Wraper for cog
! to display memory and registers

USING: accessors arrays ascii combinators
     kernel parallax.propeller.cogs.cog
      math math.parser models
       parallax.propeller.ddrx
       parallax.propeller.inx
       parallax.propeller.outx
       parallax.propeller.orx
      sequences tools.continuations vectors ;


IN: parallax.propeller.cogs

CONSTANT: COGNUMBEROF 8
CONSTANT: INA_ADDRESS 498
CONSTANT: INB_ADDRESS 499
CONSTANT: OUTA_ADDRESS 500
CONSTANT: OUTB_ADDRESS 501
CONSTANT: DDRA_ADDRESS 502
CONSTANT: DDRB_ADDRESS 503


TUPLE: logoutx < model vec ;

TUPLE: cogs cog-array num-longs ina inb outa outb ddra ddrb 
        logx ;


: <logoutx> ( -- logoutx )
    0 logoutx new-model 4 <vector> >>vec ;

M: logoutx model-changed
    [ value>> >hex " Global out change" append ] dip
    vec>> push ;


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
  [ [ ina>> INA_ADDRESS ] keep cogs-add-dependency ]
  [ [ inb>> INB_ADDRESS ] keep cogs-add-dependency ]
  bi ;


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
  ina>> in-read >hex 8 CHAR: 0 pad-head >upper
  "$" prepend swap 
  [ push ] keep ;

! make cog 0 out or with cog 1 out
: cogs-01-out ( cogs -- )
    [ [ 0 ] dip cog-array>> nth gatethree>> ]
    [ [ 1 ] dip cog-array>> nth gatethree>> ]
    bi add-dependency ;

! make cog 1 out or with cog 2 out
: cogs-12-out ( cogs -- )
    [ [ 1 ] dip cog-array>> nth gatethree>> ]
    [ [ 2 ] dip cog-array>> nth gatethree>> ]
    bi add-dependency ;

! make cog 2 out or with cog 3 out
: cogs-23-out ( cogs -- )
    [ [ 2 ] dip cog-array>> nth gatethree>> ]
    [ [ 3 ] dip cog-array>> nth gatethree>> ]
    bi add-dependency ;

! make cog 3 out or with cog 4 out
: cogs-34-out ( cogs -- )
    [ [ 3 ] dip cog-array>> nth gatethree>> ]
    [ [ 4 ] dip cog-array>> nth gatethree>> ]
    bi add-dependency ;

! make cog 4 out or with cog 5 out
: cogs-45-out ( cogs -- )
    [ [ 4 ] dip cog-array>> nth gatethree>> ]
    [ [ 5 ] dip cog-array>> nth gatethree>> ]
    bi add-dependency ;

! make cog 5 out or with cog 6 out
: cogs-56-out ( cogs -- )
    [ [ 5 ] dip cog-array>> nth gatethree>> ]
    [ [ 6 ] dip cog-array>> nth gatethree>> ]
    bi add-dependency ;

! make cog 6 out or with cog 7 out
: cogs-67-out ( cogs -- )
    [ [ 6 ] dip cog-array>> nth gatethree>> ]
    [ [ 7 ] dip cog-array>> nth gatethree>> ]
    bi add-dependency ;

! make cog 7 out or with out
: cogs-7A-out ( cogs -- )
    [ [ 7 ] dip cog-array>> nth gatethree>> ]
    [ outa>> ]
    bi add-dependency ;

! make cog 0 ddr or with cog 1 ddr
: cogs-01-ddr ( cogs -- )
    [ [ 0 ] dip cog-array>> nth gatefour>> ]
    [ [ 1 ] dip cog-array>> nth gatefour>> ]
    bi add-dependency ;

! make cog 1 ddr or with cog 2 ddr
: cogs-12-ddr ( cogs -- )
    [ [ 1 ] dip cog-array>> nth gatefour>> ]
    [ [ 2 ] dip cog-array>> nth gatefour>> ]
    bi add-dependency ;

! make cog 2 ddr or with cog 3 ddr
: cogs-23-ddr ( cogs -- )
    [ [ 2 ] dip cog-array>> nth gatefour>> ]
    [ [ 3 ] dip cog-array>> nth gatefour>> ]
    bi add-dependency ;

! make cog 3 ddr or with cog 4 ddr
: cogs-34-ddr ( cogs -- )
    [ [ 3 ] dip cog-array>> nth gatefour>> ]
    [ [ 4 ] dip cog-array>> nth gatefour>> ]
    bi add-dependency ;

! make cog 4 ddr or with cog 5 ddr
: cogs-45-ddr ( cogs -- )
    [ [ 4 ] dip cog-array>> nth gatefour>> ]
    [ [ 5 ] dip cog-array>> nth gatefour>> ]
    bi add-dependency ;

! make cog 5 ddr or with cog 6 ddr
: cogs-56-ddr ( cogs -- )
    [ [ 5 ] dip cog-array>> nth gatefour>> ]
    [ [ 6 ] dip cog-array>> nth gatefour>> ]
    bi add-dependency ;

! make cog 6 ddr or with cog 7 ddr
: cogs-67-ddr ( cogs -- )
    [ [ 6 ] dip cog-array>> nth gatefour>> ]
    [ [ 7 ] dip cog-array>> nth gatefour>> ]
    bi add-dependency ;

! make cog 7 ddr or with ddr
: cogs-7A-ddr ( cogs -- )
    [ [ 7 ] dip cog-array>> nth gatefour>> ]
    [ ddra>> ]
    bi add-dependency ;

: cogs-out-watch ( cogs -- )
    [ outa>> ]
    [ logx>> ]
    bi add-dependency ;



! this links the all the cog out to the next cog out
: cogs-link-out ( cogs -- )
    {
        [ cogs-01-out ]
        [ cogs-12-out ]
        [ cogs-23-out ]
        [ cogs-34-out ]
        [ cogs-45-out ]
        [ cogs-56-out ]
        [ cogs-67-out ]
        [ cogs-7A-out ]
        [ cogs-out-watch ]
    } cleave ;

! link the cods ddr to the next cog ddr
: cogs-link-ddr ( cogs -- )
    {
        [ cogs-01-ddr ]
        [ cogs-12-ddr ]
        [ cogs-23-ddr ]
        [ cogs-34-ddr ]
        [ cogs-45-ddr ]
        [ cogs-56-ddr ]
        [ cogs-67-ddr ]
        [ cogs-7A-ddr ]
    } cleave ;

: cogs-link-activate ( cogs -- )
    [ logx>> activate-model ]
    [ ddra>> activate-model ] bi ;


! go through all cogs and activate all memory dependecies
: cogs-activate ( cogs -- )
  cog-array>>
  [
    cog-activate
  ] each ;

: cogs-add-output ( model cogs -- )
    outa>> add-connection ;

: <cogs> ( -- cogs )
  break
  cogs new
  0 <inx> >>ina     ! INA is a global input
  0 <inx> >>inb     ! same for INB
  9 <outx> >>outa   ! global out
  0 <ddrx> >>ddra   ! global ddr
  <logoutx> >>logx  ! keep a record of out changes
  cogs-array >>cog-array
  4 >>num-longs ! this is the defult number of data longs to display
  [ cogs-set-dependency ] keep
  [ cogs-link-out ] keep
  [ cogs-link-ddr ] keep
  [ cogs-link-activate ] keep
  [ cogs-activate ] keep
;
