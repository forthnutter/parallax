! Wraper for cog
! to display memory and registers

USING: accessors arrays ascii combinators
     kernel parallax.propeller.cogs.cog
      math math.parser models
       parallax.propeller.ddrx
       parallax.propeller.inx
       parallax.propeller.outx
      sequences tools.continuations vectors 
;


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


: cogs-add-outa-memory ( cogs -- )
    [ outb>> ] keep  ! cogs ourx cogs
    cog-array>>             ! cogs outx array
    [
        [ dup ] dip         ! outx outx cog
        [ OUTA_ADDRESS ] dip cog-connection-memory ! outx outx address cog -- oux
    ] each drop
;
 
 : cogs-add-outb-memory ( cogs -- )
    [ outb>> ] keep      ! outx cogs
    cog-array>>
    [
        [ dup ] dip         ! outx outx cog
        [ OUTB_ADDRESS ] dip cog-connection-memory ! outx outx address cog -- outx
    ] each drop 
;


! set up the ddr models
: cogs-add-ddra-memory ( cogs -- )
    [ ddra>> ] keep  ! cogs ddrx cogs
    cog-array>>             ! cogs ddrx array
    [
        [ dup ] dip         ! ddrx ddrx cog
        [ DDRA_ADDRESS ] dip cog-connection-memory ! ddrx ddrx address cog -- ddrx
    ] each drop
;

: cogs-add-ddrb-memory ( cogs -- )
    [ ddrb>> ] keep      ! ddrx cogs
    cog-array>>
    [
        [ dup ] dip         ! ddrx ddrx cog
        [ DDRB_ADDRESS ] dip cog-connection-memory ! ddrx ddrx address cog -- ddrx
    ] each drop 
;


! add memory from each cog into port INA and INB
: cogs-add-memory-ina ( cogs -- )
    [ ina>> ] keep   ! cogs inx cogs
    cog-array>>             ! cogs inx array
    [
                            ! inx cog
        [ dup ] dip         ! inx inx cog
        [ INA_ADDRESS ] dip cog-memory-connection   ! inx inx address cog -- inx
    ] each [ model-value ] keep set-model
;

: cogs-add-memory-inb ( cogs -- )
    [ inb>> ] keep   ! inx cogs
    cog-array>>             ! inx array
    [
                            ! inx cog
        [ dup ] dip         ! inx inx cog
        [ INB_ADDRESS ] dip cog-memory-connection   ! inx inx address cog -- inx
    ] each [ model-value ] keep set-model
;

! need to 

! tell outa we have an object to observe what you are doing
: cogs-outa-connection ( observer cogs -- )
    outa>> outx-add-connection ;

: <cogs> ( -- cogs )
    break
    cogs new                      ! cog
    -1 <inx> >>ina
    -1 <inx> >>inb
    0 <outx> >>outa
    0 <outx> >>outb
    0 <ddrx> >>ddra
    0 <ddrx> >>ddrb
    <logoutx> >>logx  ! keep a record of out changes
    cogs-array >>cog-array

    4 >>num-longs ! this is the defult number of data longs to display
    [ cogs-add-memory-ina ] keep
    [ cogs-add-memory-inb ] keep
    [ cogs-add-outa-memory ] keep
    [ cogs-add-outb-memory ] keep
    [ cogs-add-ddra-memory ] keep
    [ cogs-add-ddrb-memory ] keep

;
