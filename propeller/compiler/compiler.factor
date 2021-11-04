! Copyright (C) 2021 forthnutter.
!

USING: arrays math math.bitwise make kernel literals accessors namespaces command-line math.parser
    sequences strings vectors io.encodings.ascii io.files io.files.info
    parallax.propeller.compilerconfig parallax.propeller.compilespin ;
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




: get-file-size ( path -- size )
    file-info size>> ;


: get-ascii-file ( pfile -- array )
    [ exists? ] keep swap
    [
        ascii file-lines 
    ] 
    [ drop f 1array ] if ;



: <compiler> ( -- )
    "C:\\Users\\jmoschini\\Downloads\\PushbuttonLedTest-v1.0.spin"
    get-ascii-file drop
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
    "Verbose" get config get verbose<<

    <compilespin>


;
