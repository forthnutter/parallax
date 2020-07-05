

IN: parallax.propeller.assembler.tests
USING: parallax.propeller.assembler math tools.test namespaces make
    sequences kernel quotations literals ;

: test-opcode ( expect quot -- )
  [ { } make first ] curry unit-test ;

: test-opcode-two ( expect quot -- )
  [ { } make first second ] curry unit-test ;

{ 0b10101000011111000000000000000000 } [ 0 0 IF_ALWAYS flags{ <#> } ABS ] test-opcode
{ 0b10101000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ABS ] test-opcode
{ 0b10101000111111000000000000000000 } [ 0 0 IF_ALWAYS flags{ <#> WR } ABS ] test-opcode
{ 0b10101001001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WC } ABS ] test-opcode
{ 0b10101001011111000000000000000000 } [ 0 0 IF_ALWAYS flags{ <#> WC } ABS ] test-opcode
{ 0b10101001101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR WC } ABS ] test-opcode
{ 0b10101001111111000000000000000000 } [ 0 0 IF_ALWAYS flags{ <#> WR WC } ABS ] test-opcode
{ 0b10101010001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WZ } ABS ] test-opcode
{ 0b10101010011111000000000000000000 } [ 0 0 IF_ALWAYS flags{ <#> WZ } ABS ] test-opcode
{ 0b10101010101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR WZ } ABS ] test-opcode
{ 0b10101010111111000000000000000000 } [ 0 0 IF_ALWAYS flags{ <#> WR WZ } ABS ] test-opcode
{ 0b10101011001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WC WZ } ABS ] test-opcode
{ 0b10101011011111000000000000000000 } [ 0 0 IF_ALWAYS flags{ <#> WC WZ } ABS ] test-opcode
{ 0b10101011101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR WC WZ } ABS ] test-opcode
{ 0b10101011111111000000000000000000 } [ 0 0 IF_ALWAYS flags{ <#> WR WC WZ } ABS ] test-opcode
{ 0b10101000010000000000000000000000 } [ 0 0 IF_NEVER flags{ <#> } ABS ] test-opcode
{ 0b10101000100000000000000000000000 } [ 0 0 IF_NEVER flags{ WR } ABS ] test-opcode
{ 0b10101000110000000000000000000000 } [ 0 0 IF_NEVER flags{ <#> WR } ABS ] test-opcode
{ 0b10101001000000000000000000000000 } [ 0 0 IF_NEVER flags{ WC } ABS ] test-opcode
{ 0b10101001010000000000000000000000 } [ 0 0 IF_NEVER flags{ <#> WC } ABS ] test-opcode
{ 0b10101001100000000000000000000000 } [ 0 0 IF_NEVER flags{ WR WC } ABS ] test-opcode
{ 0b10101001110000000000000000000000 } [ 0 0 IF_NEVER flags{ <#> WR WC } ABS ] test-opcode
{ 0b10101010000000000000000000000000 } [ 0 0 IF_NEVER flags{ WZ } ABS ] test-opcode
{ 0b10101010010000000000000000000000 } [ 0 0 IF_NEVER flags{ <#> WZ } ABS ] test-opcode
{ 0b10101010100000000000000000000000 } [ 0 0 IF_NEVER flags{ WR WZ } ABS ] test-opcode
{ 0b10101010110000000000000000000000 } [ 0 0 IF_NEVER flags{ <#> WR WZ } ABS ] test-opcode
{ 0b10101011000000000000000000000000 } [ 0 0 IF_NEVER flags{ WC WZ } ABS ] test-opcode
{ 0b10101011010000000000000000000000 } [ 0 0 IF_NEVER flags{ <#> WC WZ } ABS ] test-opcode
{ 0b10101011100000000000000000000000 } [ 0 0 IF_NEVER flags{ WR WC WZ } ABS ] test-opcode
{ 0b10101011110000000000000000000000 } [ 0 0 IF_NEVER flags{ <#> WR WC WZ } ABS ] test-opcode
{ 0b10101100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ABSNEG ] test-opcode
{ 0b10000000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ADD ] test-opcode
{ 0b10001000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ADDABS ] test-opcode
{ 0b11010000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ADDS ] test-opcode
{ 0b11011000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ADDSX ] test-opcode
{ 0b01100000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } AND ] test-opcode
{ 0b01100100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ANDN ] test-opcode
{ 0b01011100111111000000000000000000 } [ 0 0 IF_ALWAYS CALL ] test-opcode
{ 0b00001100111111000000000000000000 } [ 0   IF_ALWAYS flags{ WR } CLKSET ] test-opcode
{ 0b10000100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } CMP ] test-opcode
{ 0b11000000001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } CMPS ] test-opcode
{ 0b11100000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } CMPSUB ] test-opcode
{ 0b11000100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } CMPSX ] test-opcode
{ 0b11001100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } CMPX ] test-opcode
{ 0b00001100111111000000000000000001 } [ 0   IF_ALWAYS flags{ WR } COGID ] test-opcode
{ 0b00001100111111000000000000000010 } [ 0   IF_ALWAYS flags{ WR } COGINIT ] test-opcode
{ 0b00001100111111000000000000000011 } [ 0   IF_ALWAYS flags{ WR } COGSTOP ] test-opcode
{ 0b11100100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } DJNZ ] test-opcode
{ 0b00001100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } HUBOP ] test-opcode
{ 0b01011100001111000000000000000000 } [ 0   IF_ALWAYS flags{ } JMP ] test-opcode
{ 0b01011100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } JMPRET ] test-opcode
{ 0b00001100111111000000000000000111 } [ 0   IF_ALWAYS flags{ WR } LOCKCLR ] test-opcode
{ 0b00001100111111000000000000000100 } [ 0   IF_ALWAYS flags{ WR } LOCKNEW ] test-opcode
{ 0b00001100111111000000000000000101 } [ 0   IF_ALWAYS flags{ WR } LOCKRET ] test-opcode
{ 0b00001100111111000000000000000110 } [ 0   IF_ALWAYS flags{ WR } LOCKSET ] test-opcode
{ 0b01001100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MAX ] test-opcode
{ 0b01000100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MAXS ] test-opcode
{ 0b01001000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MIN ] test-opcode
{ 0b01000000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MINS ] test-opcode
{ 0b10100000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MOV ] test-opcode
{ 0b01010100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MOVD ] test-opcode
{ 0b01011000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MOVI ] test-opcode
{ 0b01010000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MOVS ] test-opcode
{ 0b01110000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MUXC ] test-opcode
{ 0b01110100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MUXNC ] test-opcode
{ 0b01111100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MUXNZ ] test-opcode
{ 0b01111000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } MUXZ ] test-opcode
{ 0b10100100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } NEG ] test-opcode
{ 0b10110000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } NEGC ] test-opcode
{ 0b10110100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } NEGNC ] test-opcode
{ 0b10111100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } NEGNZ ] test-opcode
{ 0b10111000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } NEGZ ] test-opcode
{ 0b00000000000000000000000000000000 } [ 0 0 IF_NEVER flags{ } NOP ] test-opcode
{ 0b01101000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } OR ] test-opcode
{ 0b00110100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } RCL ] test-opcode
{ 0b00110000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } RCR ] test-opcode
{ 0b00000000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } RDBYTE ] test-opcode
{ 0b00001000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } RDLONG ] test-opcode
{ 0b00000100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } RDWORD ] test-opcode
{ 0b01011100011111000000000000000000 } [ 0 0 IF_ALWAYS RET ] test-opcode
{ 0b00111100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } REV ] test-opcode
{ 0b00100100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ROL ] test-opcode
{ 0b00100000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } ROR ] test-opcode
{ 0b00111000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SAR ] test-opcode
{ 0b00101100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SHL ] test-opcode
{ 0b00101000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SHR ] test-opcode
{ 0b10000100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUB ] test-opcode
{ 0b10001100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUBABS ] test-opcode
{ 0b11010100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUBS ] test-opcode
{ 0b11011100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUBSX ] test-opcode
{ 0b11001100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUBX ] test-opcode
{ 0b10010000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUMC ] test-opcode
{ 0b10010100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUMNC ] test-opcode
{ 0b10011100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUMNZ ] test-opcode
{ 0b10011000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } SUMZ ] test-opcode
{ 0b01100000001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } TEST ] test-opcode
{ 0b01100100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } TESTN ] test-opcode
{ 0b11101000001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } TJNZ ] test-opcode
{ 0b11101100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } TJZ ] test-opcode
{ 0b11111000101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } WAITCNT ] test-opcode
{ 0b11110000001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } WAITPEQ ] test-opcode
{ 0b11110100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } WAITPNE ] test-opcode
{ 0b11111100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } WAITVID ] test-opcode
{ 0b00000000001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } WRBYTE ] test-opcode
{ 0b00001000001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } WRLONG ] test-opcode
{ 0b00000100001111000000000000000000 } [ 0 0 IF_ALWAYS flags{ } WRWORD ] test-opcode
{ 0b01101100101111000000000000000000 } [ 0 0 IF_ALWAYS flags{ WR } XOR ] test-opcode
