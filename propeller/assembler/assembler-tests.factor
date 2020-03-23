

IN: parallax.propeller.assembler.tests
USING: parallax.propeller.assembler math tools.test namespaces make
    sequences kernel quotations ;

: test-opcode ( expect quot -- )
  [ { } make first ] curry unit-test ;

{ 0b10101000101111000000000000000000 } [ 0 0 15 0b0010 ABS ] test-opcode
{ 0b10101100101111000000000000000000 } [ 0 0 15 0b0010 ABSNEG ] test-opcode
{ 0b10000000101111000000000000000000 } [ 0 0 15 0b0010 ADD ] test-opcode
{ 0b10001000101111000000000000000000 } [ 0 0 15 0b0010 ADDABS ] test-opcode
{ 0b11010000101111000000000000000000 } [ 0 0 15 0b0010 ADDS ] test-opcode
{ 0b11011000101111000000000000000000 } [ 0 0 15 0b0010 ADDSX ] test-opcode
{ 0b01100000101111000000000000000000 } [ 0 0 15 0b0010 AND ] test-opcode
{ 0b01100100101111000000000000000000 } [ 0 0 15 0b0010 ANDN ] test-opcode
{ 0b01011100111111000000000000000000 } [ 0 0 15 0b0011 CALL ] test-opcode
{ 0b00001100011111000000000000000000 } [ 0 0 15 0b0001 CLKSET ] test-opcode
{ 0b10000100001111000000000000000000 } [ 0 0 15 0 CMP ] test-opcode
{ 0b11000000001111000000000000000000 } [ 0 0 15 0 CMPS ] test-opcode
{ 0b11100000101111000000000000000000 } [ 0 0 15 0b0010 CMPSUB ] test-opcode
{ 0b11000100001111000000000000000000 } [ 0 0 15 0 CMPSX ] test-opcode
{ 0b11001100001111000000000000000000 } [ 0 0 15 0 CMPX ] test-opcode
{ 0b00001100111111000000000000000001 } [ 1 0 15 0b0011 COGID ] test-opcode
{ 0b00001100111111000000000000000001 } [ 1 0 15 0b0011 COGINIT ] test-opcode
{ 0b00001100011111000000000000000011 } [ 3 0 15 0b0001 COGSTOP ] test-opcode
{ 0b11100100101111000000000000000000 } [ 0 0 15 0b0010 DJNZ ] test-opcode
{ 0b00001100001111000000000000000000 } [ 0 0 15 0 HUBOP ] test-opcode
{ 0b01011100001111000000000000000000 } [ 0 0 15 0 JMP ] test-opcode
{ 0b01011100101111000000000000000000 } [ 0 0 15 0b0010 JMPRET ] test-opcode
{ 0b00001100011111000000000000000111 } [ 7 0 15 0b0001 LOCKCLR ] test-opcode
{ 0b00001100111111000000000000000100 } [ 4 0 15 0b0011 LOCKNEW ] test-opcode
{ 0b00001100011111000000000000000101 } [ 5 0 15 0b0001 LOCKRET ] test-opcode
{ 0b00001100011111000000000000000110 } [ 6 0 15 0b0001 LOCKSET ] test-opcode
{ 0b01001100101111000000000000000000 } [ 0 0 15 0b0010 MAX ] test-opcode
{ 0b01000100101111000000000000000000 } [ 0 0 15 0b0010 MAXS ] test-opcode
{ 0b01001000101111000000000000000000 } [ 0 0 15 0b0010 MIN ] test-opcode
{ 0b01000000101111000000000000000000 } [ 0 0 15 0b0010 MINS ] test-opcode
{ 0b10100000101111000000000000000000 } [ 0 0 15 0b0010 MOV ] test-opcode
{ 0b01010100101111000000000000000000 } [ 0 0 15 0b0010 MOVD ] test-opcode
{ 0b01011000101111000000000000000000 } [ 0 0 15 0b0010 MOVI ] test-opcode
{ 0b01010000101111000000000000000000 } [ 0 0 15 0b0010 MOVS ] test-opcode
{ 0b01110000101111000000000000000000 } [ 0 0 15 0b0010 MUXC ] test-opcode
{ 0b01110100101111000000000000000000 } [ 0 0 15 0b0010 MUXNC ] test-opcode
{ 0b01111100101111000000000000000000 } [ 0 0 15 0b0010 MUXNZ ] test-opcode
{ 0b01111000101111000000000000000000 } [ 0 0 15 0b0010 MUXZ ] test-opcode
{ 0b10100100101111000000000000000000 } [ 0 0 15 0b0010 NEG ] test-opcode
{ 0b10110000101111000000000000000000 } [ 0 0 15 0b0010 NEGC ] test-opcode
{ 0b10110100101111000000000000000000 } [ 0 0 15 0b0010 NEGNC ] test-opcode
{ 0b10111100101111000000000000000000 } [ 0 0 15 0b0010 NEGNZ ] test-opcode
{ 0b10111000101111000000000000000000 } [ 0 0 15 0b0010 NEGZ ] test-opcode
{ 0b00000000000000000000000000000000 } [ 0 0 0 0 NOP ] test-opcode
{ 0b01101000101111000000000000000000 } [ 0 0 15 0b0010 OR ] test-opcode
{ 0b00110100101111000000000000000000 } [ 0 0 15 0b0010 RCL ] test-opcode
{ 0b00110000101111000000000000000000 } [ 0 0 15 0b0010 RCR ] test-opcode
{ 0b00000000101111000000000000000000 } [ 0 0 15 0b0010 RDBYTE ] test-opcode
{ 0b00001000101111000000000000000000 } [ 0 0 15 0b0010 RDLONG ] test-opcode
{ 0b00000100101111000000000000000000 } [ 0 0 15 0b0010 RDWORD ] test-opcode
{ 0b01011100011111000000000000000000 } [ 0 0 15 0b0001 RET ] test-opcode
{ 0b00111100101111000000000000000000 } [ 0 0 15 0b0010 REV ] test-opcode
{ 0b00100100101111000000000000000000 } [ 0 0 15 0b0010 ROL ] test-opcode
{ 0b00100000101111000000000000000000 } [ 0 0 15 0b0010 ROR ] test-opcode
{ 0b00111000101111000000000000000000 } [ 0 0 15 0b0010 SAR ] test-opcode
{ 0b00101100101111000000000000000000 } [ 0 0 15 0b0010 SHL ] test-opcode
{ 0b00101000101111000000000000000000 } [ 0 0 15 0b0010 SHR ] test-opcode
{ 0b10000100101111000000000000000000 } [ 0 0 15 0b0010 SUB ] test-opcode
{ 0b10001100101111000000000000000000 } [ 0 0 15 0b0010 SUBABS ] test-opcode
{ 0b11010100101111000000000000000000 } [ 0 0 15 0b0010 SUBS ] test-opcode
{ 0b11011100101111000000000000000000 } [ 0 0 15 0b0010 SUBSX ] test-opcode
{ 0b11001100101111000000000000000000 } [ 0 0 15 0b0010 SUBX ] test-opcode
{ 0b10010000101111000000000000000000 } [ 0 0 15 0b0010 SUMC ] test-opcode
{ 0b10010100101111000000000000000000 } [ 0 0 15 0b0010 SUMNC ] test-opcode
{ 0b10011100101111000000000000000000 } [ 0 0 15 0b0010 SUMNZ ] test-opcode
{ 0b10011000101111000000000000000000 } [ 0 0 15 0b0010 SUMZ ] test-opcode
{ 0b01100000001111000000000000000000 } [ 0 0 15 0b0000 TEST ] test-opcode
{ 0b01100100001111000000000000000000 } [ 0 0 15 0b0000 TESTN ] test-opcode
{ 0b11101000001111000000000000000000 } [ 0 0 15 0b0000 TJNZ ] test-opcode
{ 0b11101100001111000000000000000000 } [ 0 0 15 0b0000 TJZ ] test-opcode
{ 0b11111000101111000000000000000000 } [ 0 0 15 0b0010 WAITCNT ] test-opcode
{ 0x003c0000 } [ 0 0 15 0 WRBYTE ] test-opcode
{ 0b00001000001111000000000000000000 } [ 0 0 15 0 WRLONG ] test-opcode
