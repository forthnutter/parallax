

IN: parallax.propeller.assembler.tests
USING: parallax.propeller.assembler math tools.test namespaces make
    sequences kernel quotations ;

: test-opcode ( expect quot -- )
  [ { } make first ] curry unit-test ;

{ 0b10101000001111000000000000000000 } [ 0 0 15 0 ABS ] test-opcode
{ 0x003c0000 } [ 0 0 15 0 WRBYTE ] test-opcode
{ 0b00001000001111000000000000000000 } [ 0 0 15 0 WRLONG ] test-opcode
