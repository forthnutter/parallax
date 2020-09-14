\ ****************************************************
\ CogMem.f
\ Cog memory
\ ****************************************************

0x0000 CONSTANT RAMSTART
0x01EF CONSTANT RAMEND
0x01F0 CONSTANT RAMSIZE

0x01F0 CONSTANT PARADDR
0x01F1 CONSTANT CNTADDR
0x01F2 CONSTANT INAADDR
0x01F3 CONSTANT INBADDR
0x01F4 CONSTANT OUTAADDR
0x01F5 CONSTANT OUTBADDR
0x01F6 CONSTANT DIRAADDR
0x01F7 CONSTANT DIRBADDR
0x01F8 CONSTANT CTRAADDR
0x01F9 CONSTANT CTRBADDR
0x01FA CONSTANT FRQAADDR
0x01FB CONSTANT FRQBADDR
0x01FC CONSTANT PHSAADDR
0x01FD CONSTANT PHABADDR
0x01FE CONSTANT VCFGADDR
0x01FF CONSTANT VSCLADDR


:Class CogMemory <Super Object
        0 VALUE MEM

        0 VALUE PAR
        0 VALUE CNT
        0 VALUE INA
        0 VALUE INB
        0 VALUE OUTA
        0 VALUE OUTB
        0 VALUE DIRA
        0 VALUE DIRB
        0 VALUE CTRA
        0 VALUE CTRB
        0 VALUE FRQA
        0 VALUE FRQB
        0 VALUE PHSA
        0 VALUE PHSB
        0 VALUE VCFG
        0 VALUE VSCL

        :M Reset:       ( -- )
                0 TO MEM
                0 TO PAR 0 TO CNT
                0 TO INA 0 TO INB
                0 TO OUTA 0 TO OUTB
                0 TO DIRA 0 TO DIRB
                0 TO CTRA 0 TO CTRB
                0 TO FRQA 0 TO FRQB
                0 TO PHSA 0 TO PHSB
                0 TO VCFG 0 TO VSCL ;M

        :M ClassInit:   ( -- )
                ClassInit: super
                Reset: self
                CELL RAMSIZE * ALLOCATE
                IF DROP ELSE TO MEM THEN ;M


        :M ~:           ( -- )
                MEM
                IF MEM FREE
                        IF 0 TO MEM THEN
                THEN    ;M

        :M DUMP:
                CELL RAMSIZE * 0
                ?DO
                        CR I 4 h.R ."  | "
                        I 8 + I
                        DO
                                MEM I + C@ H.8 SPACE
                        LOOP
                        ." | "
                        I 16 + I
                        DO
                                MEM I + C@ DUP
                                0x20 <
                                IF
                                        DROP ." ."
                                ELSE
                                        DUP 0x7F >
                                        IF
                                                DROP ." ."
                                        ELSE
                                                EMIT
                                        THEN
                                THEN
                        LOOP
                        ."  | "

                16 +LOOP
        ;M

        :M READ:        ( a -- l )
                CELL *  \ generate real adress
                DUP
                0x0000200 <
                IF
                        MEM + @
                ELSE
                        DROP
                        0
                THEN
        ;M


;Class


