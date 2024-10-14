! Wraper for cog
! to display memory and registers

USING: accessors arrays ascii combinators
     kernel parallax.propeller.cogs.cog
      math math.bitwise math.parser models
       parallax.propeller.inx
      sequences tools.continuations vectors 
;


IN: parallax.propeller.cogs

CONSTANT: COGNUMBEROF 8





TUPLE: logoutx < model vec ;

TUPLE: cogs cog-array num-longs ina inb logx ;


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


: cogs-src-dst ( cogs -- $array )
    COGNUMBEROF <vector>
    swap cog-array>>
    [
        [ cog-active? ] keep swap
        [ pc-src-dst swap [ push ] keep ] [ drop ] if
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
        ! inx-add-connection  ! cogs
        inx-add-dependency
    ] each drop ;

! get cog inb memory and make it an observer of global INB
: cogs-inb-connect ( cogs -- )
    [ cog-array>> ] keep swap   ! cogs array
    [
        ! cogs cog
        [ [ inb>> ] keep swap ] dip ! cogs inx cog
        cog-inb-model swap  ! cogs model inx
        ! inx-add-connection  ! cogs
        inx-add-dependency
    ] each drop ;


: get-orout-model ( n cogs -- model )
    cog-array>> nth oraout>> ;

: get-orddr-model ( n cogs -- model )
    cog-array>> nth oraddr>> ;


: out-link ( cogs -- cogs )
    [ [ 1 swap get-orout-model ] [ 0 swap get-orout-model ] bi add-dependency ] keep
    [ [ 2 swap get-orout-model ] [ 1 swap get-orout-model ] bi add-dependency ] keep
    [ [ 3 swap get-orout-model ] [ 2 swap get-orout-model ] bi add-dependency ] keep
    [ [ 4 swap get-orout-model ] [ 3 swap get-orout-model ] bi add-dependency ] keep
    [ [ 5 swap get-orout-model ] [ 4 swap get-orout-model ] bi add-dependency ] keep
    [ [ 6 swap get-orout-model ] [ 5 swap get-orout-model ] bi add-dependency ] keep
    [ [ 7 swap get-orout-model ] [ 6 swap get-orout-model ] bi add-dependency ] keep
    [ [ 7 swap get-orout-model ] [ ina>> ] bi add-dependency ] keep
    [ ina>> activate-model ] keep
!    [ 7 swap get-orout-model activate-model ] keep
;

: ddr-link ( cogs -- cogs )
    [ [ 1 swap get-orddr-model ] [ 0 swap get-orddr-model ] bi add-dependency ] keep
    [ [ 2 swap get-orddr-model ] [ 1 swap get-orddr-model ] bi add-dependency ] keep
    [ [ 3 swap get-orddr-model ] [ 2 swap get-orddr-model ] bi add-dependency ] keep
    [ [ 4 swap get-orddr-model ] [ 3 swap get-orddr-model ] bi add-dependency ] keep
    [ [ 5 swap get-orddr-model ] [ 4 swap get-orddr-model ] bi add-dependency ] keep
    [ [ 6 swap get-orddr-model ] [ 5 swap get-orddr-model ] bi add-dependency ] keep
    [ [ 7 swap get-orddr-model ] [ 6 swap get-orddr-model ] bi add-dependency ] keep
    [ [ inb>> ] [ 7 swap get-orddr-model ] bi add-dependency ] keep
    [ 7 swap get-orddr-model activate-model ] keep
;

: cogs-dump ( address cogn cogs -- vector )
    [ 1 ] 3dip 
    [ swap ] dip 
    cogs-mdl ;

! get the hex string of ina
: ina-hex ( cogs -- hex )
    ina>> in-read 32 bits >hex "0x" prepend ;


! builds up the array of cogs
: <cogs> ( -- cogs )
    cogs new                      ! cog
    -1 <inx> >>ina
    -1 <inx> >>inb
    <logoutx> >>logx  ! keep a record of out changes
    cogs-array >>cog-array
    4 >>num-longs ! this is the defult number of data longs to display
    [ cogs-ina-connect ] keep
    [ cogs-inb-connect ] keep
    break
    out-link ddr-link

;
