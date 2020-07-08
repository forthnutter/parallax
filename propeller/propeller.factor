! Copyright (C) 2020 forthnutter.
!

USING: math math.bitwise make kernel literals parallax.propeller.assembler
  parallax.propeller.assembler.cog
  compiler.codegen.labels namespaces accessors sequences arrays hashtables
  assocs ;

IN: parallax.propeller

REGISTER: param 0x1E0

: start ( -- d )
  [
    PAR param IF_ALWAYS flags{ WR } MOV
  ] { } make ;
