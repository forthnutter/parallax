\ *******************************************************
\ Processor.f
\ *****************************************************


\ make a record of the instruction format
:Class Instruct <Super Object
        0 VALUE I

        :M Reset:       ( -- )
                0 TO I ;M

        :M ClassInit:   ( -- )
                ClassInit: super
                Reset: self
        ;M

        \ write to Instruction
        :M I!:          ( u -- )
                TO I ;M

        \ read instruction
        :M I@:          ( -- u )
                I ;M

        \ Get the opcode value
        :M OPCODE@:     ( -- u )
                0xFC000000 I AND 26 RSHIFT ;M

        \ Get the write to z flag
        :M WZ@:          ( -- b )
                0x02000000 I AND 25 RSHIFT ;M

        \ get the write to c flag
        :M WC@:          ( -- b )
                0x01000000 I AND 24 RSHIFT ;M

        \ Get the write to destination bit
        :M WD@:         ( -- b )
                0x00800000 I AND 23 RSHIFT ;M

        \ Get the constant flag
        :M CONST@:      ( -- b )
                0x00400000 I AND 22 RSHIFT ;M

        \ Get the exc conditions
        :M EXCON@:      ( -- u )
                0x003C0000 I AND 18 RSHIFT ;M

        \ Get Destination Register
        :M D@:          ( -- u )
                0x0003FE00 I AND 9 RSHIFT ;M

        \ Get the Source register
        :M S@:          ( -- u )
                0x000001FF I AND ;M

;Class



