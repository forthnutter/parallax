! disasembler for Parallax Propeller P8X32A

USING: accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise models ascii
    parallax.propeller.cogs.cog hashtables ;

IN: parallax.propeller.cogs.cogdisasm


TUPLE: cogdasm labels ;

: >hex-pad3 ( d -- $ )
  >hex 3 CHAR: 0 pad-head >upper ;

: >hex-pad2 ( d -- $ )
  >hex 2 CHAR: 0 pad-head >upper ;

: opcode-error ( cog -- $ )
  drop
  "ILLEGAL-INSTRUCTION" ;


: label-exstract ( address cogdisasm -- $/? )
  labels>> at ;

! source destination condition flags opcode
: source-exstract ( code -- source )
  9 bits ;

! source destination condition flags opcode
: source-exstract$ ( code cogdisasm -- source )
  [ [ source-exstract ] dip label-exstract ] 2keep drop swap dup
  [ swap drop ] [ drop source-exstract >hex-pad3 "0x" prepend ] if ;

: dest-exstract ( code -- dest )
  17 9 bit-range ;

: dest-exstract$ ( code cogdisasm -- $ )
  [ [ dest-exstract ] dip label-exstract ] 2keep drop swap dup
  [ swap drop ] [ drop dest-exstract >hex-pad3 "0x" prepend ] if ;

: flags-exstract ( code -- flags )
  25 22 bit-range ;

: cond-exstract ( code -- cond )
  21 18 bit-range ;


! test for nop condition
: cond-exstract$ ( code -- $/f )
  cond-exstract
  H{
    { 0 "NEVER" } { 1 "IF_NC_AND_NZ" } { 2 "IF_NC_AND_Z" }
    { 3 "IF_NC" } { 4 "IF_C_AND_NZ" } { 5 "IF_NZ" }
    { 6 "IF_C_NE_Z" } { 7 "IF_NC_OR_NZ" } { 8 "IF_C_AND_Z" }
    { 9 "IF_C_EQ_Z" } { 10 "IF_Z" } { 11 "IF_NC_OR_Z" }
    { 12 "IF_C" } { 13 "IF_C_OR_NZ" } { 14 "IF_C_OR_Z" }
    { 15 "ALLWAYS" }
  } at ;

: flag-imd ( code -- ? )
  22 bit? ;

! flags display
: flag-imd$ ( code -- $ )
  flag-imd [ "<#>" ] [ " " ] if ;

: flag-r ( code -- ? )
  23 bit? ;

: flag-r$ ( flags --  $ )
  flag-r [ "WR" ] [ " " ] if ;

: flag-c ( code -- ? )
  24 bit? ;

: flag-c$ ( flags -- $ )
  flag-c [ "WC" ] [ " " ] if ;

: flag-z ( code -- ? )
  25 bit? ;

: flag-z$ ( flag -- $ )
  flag-z [ "WZ" ] [ " " ] if ;

: flag$ ( flags -- $ )
  [ "flags{ " ] dip
  [ flag-z$ " " append ] keep [ append ] dip
  [ flag-c$ " " append ] keep [ append ] dip
  [ flag-r$ " " append ] keep [ append ] dip
  flag-imd$ " " append append "}" append ;

: opcode-exstract ( d -- op )
  31 26 bit-range ;


: opcode-subcode ( code -- $/? )
  [ flag-r ] keep swap
  [
    opcode-exstract
    H{
      { 0 "RDBYTE" } { 1 "RDWORD" } { 2 "RDLONG" }
      { 23 "JMPRET" } { 24 "AND" } { 33 "SUB" }
    } at
    dup [ ] [ drop "ERROR" ] if
  ]
  [
    opcode-exstract
    H{
      { 0 "WRBYTE" } { 1 "WRWORD" } { 2 "WRLONG" }
      { 23 "JMP" } { 24 "TEST" } { 33 "CMP" }
    } at
    dup [ ] [ drop "ERROR" ] if
  ] if ;

: opcode-exstract$ ( code -- $/? )
  [ opcode-exstract ] keep swap
  H{
    { 1 "DWORD" } { 2 "DLONG" }
    { 3 "SYSOP" } { 8 "ROR" }
    { 9 "ROL" } { 10 "SHR" } { 11 "SHL" }
    { 12 "RCR" } { 13 "RCL" } { 14 "SAR" }
    { 15 "REV" } { 16 "MINS" } { 17 "MAXS" }
    { 18 "MIN" } { 19 "MAX" } { 20 "MOVS" }
    { 21 "MOVD" } { 22 "MOVI" } { 23 "JMPRET" }
    { 24 "AND" } { 25 "ANDN" } { 26 "OR" }
    { 27 "XOR" } { 28 "MUXC" } { 29 "MUXNC" }
    { 30 "MUXZ" } { 31 "MUXNZ" } { 32 "ADD" }
    { 33 "SUB" } { 34 "ADDABS" } { 35 "SUBABS" }
    { 36 "SUMC" } { 37 "SUMNC" } { 38 "SUMZ" }
    { 39 "SUMNZ" } { 40 "MOV" } { 41 "NEG" }
    { 42 "ABS" } { 43 "ABSNEG" } { 44 "NEGC" }
    { 45 "NEGNC" } { 46 "NEGZ" } { 47 "NEGNZ" }
    { 48 "CMPS" } { 49 "CMPSX" } { 50 "ADDX" }
    { 51 "SUBX" } { 52 "ADDS" } { 53 "SUBS" }
    { 54 "ADDSX" } { 55 "SUBSX" } { 56 "CMPSUB" }
    { 57 "DJNZ" } { 58 "TJNZ" } { 59 "TJZ" }
    { 60 "WAITPEQ" } { 61 "WAITPNE" } { 62 "WAITCNT" }
    { 63 "WAITVID" }
  } at
  dup [ swap drop ] [ drop opcode-subcode ] if ;




: opcode-string ( code cogdisasm -- $ )
  [ source-exstract$ " " append ] 2keep
  [ dest-exstract$ " " append ] 2keep drop [ append ] dip
  [ cond-exstract$ " " append ] keep [ append ] dip
  [ flag$ " " append ] keep [ append ] dip
  opcode-exstract$ append ;

: dasm-add ( label address  cogdisasm -- )
  labels>> ?set-at drop ;


: <cogdasm> ( -- cogdasm )
  cogdasm new
  H{ } clone >>labels ;
