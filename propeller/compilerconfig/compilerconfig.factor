! Copyright (C) 2019 forthnutter.
!

USING: math math.bitwise make kernel literals accessors ;
IN: parallax.propeller.compilerconfig



TUPLE: compilerconfig verbose quiet filetreeoutputonly filelistoutputonly dumpsymbols
        usepreprocessor alternatepreprocessormode unusedmethodelimination docmode datonly
        binary eeprom-size ;

GENERIC: init ( obj -- )


M: compilerconfig init

drop
;

: <compilerconfig> ( -- compilerconfig )
    compilerconfig new
    f >>verbose
    f >>quiet
    f >>filetreeoutputonly
    f >>filelistoutputonly
    f >>dumpsymbols
    f >>usepreprocessor
    f >>alternatepreprocessormode
    f >>unusedmethodelimination
    f >>docmode
    f >>datonly
    t >>binary
    32768 >>eeprom-size ;

