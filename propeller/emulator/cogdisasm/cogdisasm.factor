! disasembler for Parallax Propeller P8X32A

USING: accessors arrays kernel math sequences byte-arrays io
    math.parser math.ranges unicode.case namespaces parser lexer
    tools.continuations peg fry assocs combinators sequences.deep make
    words quotations math.bitwise models ascii
    parallax.propeller.emulator.cog ;

IN: parallax.propeller.emulator.cogdisasm


TUPLE: cogdisasm opcodes source dest labels ;

: >hex-pad3 ( d -- $ )
  >hex 3 CHAR: 0 pad-head >upper ;

: >hex-pad2 ( d -- $ )
  >hex 2 CHAR: 0 pad-head >upper ;

: opcode-error ( cog -- $ )
  drop
  "ILLEGAL-INSTRUCTION" ;


: cond-exstract ( code -- cond )
  21 18 bit-range ;

! source destination condition flags opcode
: source-exstract ( code -- source )
  9 bits ;

! source destination condition flags opcode
: source-exstract$ ( code -- source )
  source-exstract >hex-pad3 "0x" prepend ;


: dest-exstract ( code -- dest )
  17 9 bit-range ;

: dest-exstract ( code -- $ )
  dest-exstract >hex-pad3 "0x" prepend ;

: flags-exstract ( code -- flags )
  25 22 bit-range ;

! test for nop condition
: condition-nop ( code -- $/? )
  cond-exstract 0 =
  [ "NOP" ] [ f ] if ;

: (opcode-00) ( code -- $ )
  break
  [ source-exstract$ " " append ] keep
  [ dest-extract$ " " append ] keep
  [ condition-nop ] keep swap dup
  [ swap drop ]
  [ drop drop "RD/WRBYTE" ] if append ;

: (opcode-01) ( array -- $ )
  drop "RD/WRWORD" ;

: (opcode-02) ( array -- $ )
  drop "RD/WRLONG" ;

: (opcode-03) ( array -- $ )
  drop "SYSOP" ;

: (opcode-08) ( array -- $ )
  drop "ROR" ;

: (opcode-09) ( array -- $ )
  drop "ROL" ;

: (opcode-0A) ( array -- $ )
  drop "SHR" ;

: (opcode-0B) ( array -- $ )
  drop "SHL" ;

: (opcode-0C) ( array -- $ )
  drop "RCR" ;

: (opcode-0D) ( array -- $ )
  drop "RCL" ;

: (opcode-0E) ( array -- $ )
  drop "SAR" ;

: (opcode-0F) ( array -- $ )
  drop "REV" ;

: (opcode-10) ( array -- $ )
  drop "MINS" ;

: (opcode-11) ( array -- $ )
  drop "MAXS" ;

: (opcode-12) ( array -- $ )
  drop "MIN" ;

: (opcode-13) ( array -- $ )
  drop "MAX" ;

: (opcode-14) ( array -- $ )
  drop "MOVS" ;

: (opcode-15) ( array -- $ )
  drop "MOVD" ;

: (opcode-16) ( array -- $ )
  drop "MOVI" ;

: (opcode-17) ( array -- $ )
  drop "JMPRET" ;

: (opcode-18) ( array -- $ )
  drop "AND" ;

: (opcode-19) ( array -- $ )
  drop "ANDN" ;

: (opcode-1A) ( array -- $ )
  drop "OR" ;

: (opcode-1B) ( array -- $ )
  drop "XOR" ;

: (opcode-1C) ( array -- $ )
  drop "MUXC" ;

: (opcode-1D) ( array -- $ )
  drop "MUXNC" ;

: (opcode-1E) ( array -- $ )
  drop "MUXZ" ;

: (opcode-1F) ( array -- $ )
  drop "MUXNZ" ;

: (opcode-20) ( array -- $ )
  drop "ADD" ;

: (opcode-21) ( array -- $ )
  drop "SUB" ;

: (opcode-22) ( array -- $ )
  drop "ADDABS" ;

: (opcode-23) ( array -- $ )
  drop "SUBABS" ;

: (opcode-24) ( array -- $ )
  drop "SUMC" ;

: (opcode-25) ( array -- $ )
  drop "SUMNC" ;

: (opcode-26) ( array -- $ )
  drop "SUMZ" ;

: (opcode-27) ( array -- $ )
  drop "SUMNZ" ;

: (opcode-28) ( array -- $ )
  drop "MOV" ;

: (opcode-29) ( array -- $ )
  drop "NEG" ;

: (opcode-2A) ( array -- $ )
  drop "ABS" ;

: (opcode-2B) ( array -- $ )
  drop "ABSNEG" ;

: (opcode-2C) ( array -- $ )
  drop "NEGC" ;

: (opcode-2D) ( array -- $ )
  drop "NEGNC" ;

: (opcode-2E) ( array -- $ )
  drop "NEGZ" ;

: (opcode-2F) ( array -- $ )
  drop "NEGNZ" ;

: (opcode-30) ( array -- $ )
  drop "CMPS" ;

: (opcode-31) ( array -- $ )
  drop "CMPSX" ;

: (opcode-32) ( array -- $ )
  drop "ADDX" ;

: (opcode-33) ( array -- $ )
  drop "SUBX" ;

: (opcode-34) ( array -- $ )
  drop "ADDS" ;

: (opcode-35) ( array -- $ )
  drop "SUBS" ;

: (opcode-36) ( array -- $ )
  drop "ADDSX" ;

: (opcode-37) ( array -- $ )
  drop "SUBSX" ;

: (opcode-38) ( array -- $ )
  drop "CMPSUB" ;

: (opcode-39) ( array -- $ )
  drop "DJNZ" ;

: (opcode-3A) ( array -- $ )
  drop "TJNZ" ;

: (opcode-3B) ( array -- $ )
  drop "TJZ" ;

: (opcode-3C) ( array -- $ )
  drop "WAITPEQ" ;

: (opcode-3D) ( array -- $ )
  drop "WAITPNE" ;

: (opcode-3E) ( array -- $ )
  drop "WAITCNT" ;

: (opcode-3F) ( array -- $ )
  drop "WAITVID" ;

: opcode-extract ( d -- op )
  31 26 bit-range ;

! disassemble an array of data
: cogdisasm-code ( code disasm -- $ )
  [ drop opcode-extract ] 2keep
  opcodes>> nth call( code -- $ ) ;

! generate the string opcode array here
: opcode-build ( dis -- )
  opcodes>> dup
  [
    [ drop ] dip
    [
      >hex-pad2
      "(opcode-" swap append ")" append
      "parallax.propeller.emulator.cogdisasm" lookup-word dup
      [ 1quotation ] [ drop [ opcode-error ] ] if
    ] keep
    [ swap ] dip swap [ set-nth ] keep
  ] each-index drop ;


: <cogdisasm> ( -- cogdisasm )
  cogdisasm new
  64 [ opcode-error ] <array> >>opcodes
  H{ } clone >>labels
  [ opcode-build ] keep ;
