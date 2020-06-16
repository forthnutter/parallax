! Copyright (C) 2019 forthnutter.
!

USING: math math.bitwise make kernel literals parallax.propeller.assembler
  namespaces arrays accessors parser words words.symbol words.constant
  sequences tools.continuations ;
IN: parallax.propeller.assembler.cog




TUPLE: cog number memory ;

<<

CONSTANT: cog-variables 0x100
SYMBOL: variables-start
cog-variables variables-start set-global

SYNTAX: COG-VARIABLE:
  scan-new-word
  variables-start get
  [ define-constant ]
  [ 1 + variables-start set ]
  bi ;
>>


COG-VARIABLE: parm
COG-VARIABLE: num

SYMBOL: cold-start

: MOVA ( src dest -- array )
  [ IF_ALWAYS flags{ WR } MOV ] 2curry
  { } make ;

[
  PAR parm IF_ALWAYS flags{ WR } MOV
  parm num IF_ALWAYS flags{ WR } RDLONG
] { } make cold-start set


! make cog structure
: <cog> ( -- cog )
cog new
512 0 <array> >>memory ;
