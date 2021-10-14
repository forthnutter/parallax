! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig  ;
IN: parallax.propeller.compiler


SYMBOL: config
SYMBOL: pathentry
SYMBOL: outfile

! add path string to 
: add-pathentry ( string -- )
    dup string?
    [
        pathentry get push
    ]
    [ drop ] if  
;

: clean-pathentry ( -- )
    pathentry get delete-all ;


: <compiler> ( -- )
    <compilerconfig> config set     ! make conf tuple
    16 <vector> pathentry set       ! create somewhere to store paths

    (command-line) "-PrePro" suffix parse-command-line

    "Include" get [ add-pathentry ] when*
    "Output" get [ outfile set ] when*
    "PrePro" get [ config get usepreprocessor<< ] when*
    "EEProm" get [ string>number config get eeprom-size<< ] when*
    "AltPre" get config get alternatepreprocessormode<<
    "TreeObj" get config get filetreeoutputonly<<
    "FileList" get config get filelistoutputonly<<
    "Binary" get config get binary<<
    "Dat" get config get datonly<<
    "Quiet" get config get quiet<<
    ""
;
