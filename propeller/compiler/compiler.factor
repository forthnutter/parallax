! Copyright (C) 2021 forthnutter.
!

USING: arrays math math.bitwise make kernel literals accessors
    namespaces command-line math.parser tools.continuations
    sequences strings vectors io.encodings.ascii io.files io.files.info
    parallax.propeller.compilerconfig parallax.propeller.compilespin
    parallax.propeller.pathentry ;

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



! returns NULL if the file failed to open or is 0 length
: loadfile ( pFilename pnLength ppFilePath -- vector )
    drop drop drop 
!    pBuffer = 0;
!    FILE* pFile = OpenFileInPath(pFilename, "rb");
!    if (pFile != NULL)
!    {
        ! get the length of the file by seeking to the end and using ftell
!        fseek(pFile, 0, SEEK_END);
!        *pnLength = ftell(pFile);

!        if (*pnLength > 0)
!        {
!            pBuffer = (char*)malloc(*pnLength+1); // allocate a buffer that is the size of the file plus one char
!            pBuffer[*pnLength] = 0; // set the end of the buffer to 0 (null)

!            // seek back to the beginning of the file and read it in
!            fseek(pFile, 0, SEEK_SET);
!            fread(pBuffer, 1, *pnLength, pFile);
!        }

!        fclose(pFile);

!        *ppFilePath = &(s_filesAccessed[s_nFilesAccessed-1][0]);
!    }
!    else
!    {
!        return 0;
!    }

    V{ } clone ;


: freefilebuffer ( pBuffer -- )
    [ vector? ] keep swap
    [ drop ] [ drop ] if
;



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

    break
    <pathentry>
    "C:\\Users\\jmoschini\\Downloads\\PushbuttonLedTest-v1.0.spin"
    AddFilePath drop

    config get
    \ loadfile
    \ freefilebuffer
    <compilespin>


;
