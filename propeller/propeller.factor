! Copyright (C) 2020 forthnutter.
!

USING: math math.bitwise make kernel literals
    parallax.propeller.assembler
    parallax.propeller.assembler.cog
    parallax.propeller.hub
  compiler.codegen.labels
    models namespaces accessors sequences arrays hashtables
  assocs tools.continuations ;

IN: parallax.propeller

REGISTER: t1 0x1E0
REGISTER: t2 0x1E1
REGISTER: rxmask 0x1E2
REGISTER: txmask 0x1E3
REGISTER: rxtxmode 0x1E4
REGISTER: bitticks 0x1E5
REGISTER: rxbuff 0x1E6
REGISTER: txbuff 0x1E7
REGISTER: txcode 0x1E8


CONSTANT: BUFFER_LENGTH 64

TUPLE: propeller hub ;


: start ( cog -- cog' )

  [
!    init-relocation
    PAR t1 IF_ALWAYS flags{ WR } MOV            ! get structure address
    4 2 shift t1 IF_ALWAYS flags{ <#> WR } ADD  ! skip past head and tails

    t1 t2 IF_ALWAYS flags{ WR } RDLONG          ! get rx_pin
    1 rxmask IF_ALWAYS flags{ WR <#> } MOV
    t2 rxmask IF_ALWAYS flags{ WR } SHL

    4 t1 IF_ALWAYS flags{ WR <#> } ADD          ! get tx_pin
    t1 t2 IF_ALWAYS flags{ WR } RDLONG
    1 txmask IF_ALWAYS flags{ WR <#> } MOV
    t2 txmask IF_ALWAYS flags{ WR } SHL

    4 t1 IF_ALWAYS flags{ WR <#> } ADD           ! get rxtx_mode
    t1 rxtxmode IF_ALWAYS flags{ WR } RDLONG

    4 t1 IF_ALWAYS flags{ WR <#> } ADD          ! get bit_ticks
    t1 bitticks IF_ALWAYS flags{ WR } RDLONG

    4 t1 IF_ALWAYS flags{ WR <#> } ADD           ! get buffer_ptr
    t1 rxbuff IF_ALWAYS flags{ WR } RDLONG
    rxbuff txbuff IF_ALWAYS flags{ WR } MOV
    BUFFER_LENGTH txbuff IF_ALWAYS flags{ WR <#> } ADD

    0b0100 rxtxmode IF_ALWAYS flags{ <#> WZ } TEST  ! init tx pin according to mode
    0b0010 rxtxmode IF_ALWAYS flags{ <#> WC } TEST
    txmask OUTA IF_Z_NE_C flags{ WR } OR
    txmask DIRA IF_Z flags{ WR } OR
    break
    ! "transmit" define-label
    ! "transmit" get txcode IF_ALWAYS flags{ <#> WR } MOV ! init ping-pong multitask
    ! txcode "transmit" get pmova


    "transmit" resolve-label
  ] { } make swap cog-code ;

: stest ( cog -- cog )
  [
    [
      break
      "end" define-label
      PAR t1 IF_ALWAYS flags{ WR } MOV
!      t1 "end" get pmova

    ] with-scope
    { 1 } ,
  ] { } make cog-code ;

: pmain ( -- )
  <cog> stest start drop ;

! need to add module to output
: propeller-add-output ( model propeller --  )
    hub>> hub-add-output ;

! kind of a wrapper
: propeller-step ( propeller -- )
    hub>> hub-step drop ;

: propeller-pc-alist ( propeller -- )
    hub>> hub-pc-alist drop ;

: propeller-alist ( address propeller -- slist )
    hub>> hub-cog-alist ;

: propeller-run-address ( address cogn propeller -- )
    hub>> hub-run-address ;

: <propeller> ( -- propeller )
    propeller new
    <hub> >>hub ;