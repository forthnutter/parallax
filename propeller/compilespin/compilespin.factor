! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig  ;
IN: parallax.propeller.compilespin

TUPLE: compilerspin verbose quiet filetressoutputonly filelistoutputonly dump usepreprocessor
        alternatepreprocessormode unusedmethodelimination docmode datonly binary eeprom-size ;


: <compilerspin> ( -- cs )



;


