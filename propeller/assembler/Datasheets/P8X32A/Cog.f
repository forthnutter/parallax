\ One Cog
\ Cog.f

needs Processor.f
needs CogMem.f

:Object COG <Super Object
        0 VALUE PC
        CogMemory CM
        Instruct CI

        :M DUMP:
                DUMP: CM
        ;M

        :M RESET:
                0 TO PC
                RESET: CM
                RESET: CI
        ;M

        :M EXEONE:
                PC
                READ: CM
                I!: CI
                PC 1 + TO PC

                OPCODE@: CI
                CASE
                        0 OF RDBYTE ENDOF
                        1 OF RDWORD ENDOF
                        2 OF RDLONG ENDOF
                        3 OF
        ;M

        :M PC@: PC ;M

;Object
