! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig parallax.propeller.preprocess ;
IN: parallax.propeller.compilespin

TUPLE: compilespin verbose quiet filetressoutputonly filelistoutputonly dump usepreprocessor
        alternatepreprocessormode unusedmethodelimination docmode datonly binary eeprom-size
        freefile loadfile pp ;

! lff = load file func
! ffbf free file buffer function
: <compilespin> ( lff ffbf -- cs )
        compilespin new
        swap >>freefile
        swap >>loadfile

        [ alternatepreprocessormode>> <preprocess> ] keep swap >>pp 

        [ loadfile>> ] [ freefile>> ] [ pp>> pp-set-file-func ] tri 
;


