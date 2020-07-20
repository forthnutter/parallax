! Copyright (C) 2020 forthnutter.
!

USING: math math.bitwise make kernel literals parallax.propeller.assembler
  parallax.propeller.assembler.cog
  compiler.codegen.labels namespaces accessors sequences arrays hashtables
  assocs ;

IN: parallax.propeller

REGISTER: t1 0x1E0
REGISTER: t2 0x1E1
REGISTER: rxmask 0x1E2


: start ( cog -- cog' )
  [
    PAR t1 IF_ALWAYS flags{ WR } MOV
    4 2 shift t1 IF_ALWAYS flags{ <#> WR } ADD
    t1 t2 IF_ALWAYS flags{ WR } RDLONG
    1 rxmask IF_ALWAYS flags{ WR <#> } MOV
    t2 rxmask IF_ALWAYS flags{ WR } SHL
  ] { } make swap cog-code ;


: pmain ( -- )
  <cog> start drop ;
