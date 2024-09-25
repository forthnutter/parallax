! Wraper for cog
! to display memory and registers

USING: accessors arrays ascii combinators
     kernel parallax.propeller.cogs.cog
      math math.parser models
       parallax.propeller.ddrx
       parallax.propeller.inx
      sequences tools.continuations vectors 
;


IN: parallax.propeller.cogs

CONSTANT: COGNUMBEROF 8



CONSTANT: DDRA_ADDRESS 502
CONSTANT: DDRB_ADDRESS 503


TUPLE: logoutx < model vec ;

TUPLE: cogs cog-array num-longs ina inb ddra ddrb 
    logx
;


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

! create an instance of 8 cogs with ports
: cogs-array-port ( cogs -- )
    break
    cog-array>>
    [
        drop
        
    ] each ;

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



: cogs-get-cog ( cogn cogs -- cog )
    cog-array>>     ! cogn array 
    nth             ! cog
;

! do execute cog till it reaches address
: cogs-cog-run-address ( address cogn cogs -- )
    cogs-get-cog cog-execute-address ;



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


! display cogs disasembler from address
: cogs-alist ( address cogs -- vector )
    [ COGNUMBEROF <vector> ] 2dip   ! make an array for return
    cog-array>>                     ! get the array of cogs
    [
        [ cog-active? ] keep swap
        [ [ cog-list swap [ push ] keep ] 2keep drop ]
        [ drop ] if
    ] each drop ;

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



! get cog ina memory and make it an observer of global INA
: cogs-ina-connect ( cogs -- )
    [ cog-array>> ] keep swap ! cogs array
    [
        ! cogs cog
        [ [ ina>> ] keep swap ] dip ! cogs inx cog
        cog-ina-model swap  ! cogs model inx
        inx-add-connection  ! cogs
    ] each drop ;

! get cog inb memory and make it an observer of global INB
: cogs-inb-connect ( cogs -- )
    [ cog-array>> ] keep swap   ! cogs array
    [
        ! cogs cog
        [ [ inb>> ] keep swap ] dip ! cogs inx cog
        cog-inb-model swap  ! cogs model inx
        inx-add-connection  ! cogs
    ] each drop ;





: cogs-dump ( address cogn cogs -- vector )
    [ 1 ] 3dip 
    [ swap ] dip 
    cogs-mdl ;

: cogs-ina-hex ( cogn cogs -- vector )

;

: <cogs> ( -- cogs )
    break
    cogs new                      ! cog
    -1 <inx> >>ina
    -1 <inx> >>inb
    0 <ddrx> >>ddra
    0 <ddrx> >>ddrb
    <logoutx> >>logx  ! keep a record of out changes
    cogs-array >>cog-array

    4 >>num-longs ! this is the defult number of data longs to display
    [ cogs-ina-connect ] keep
    [ cogs-inb-connect ] keep


;
