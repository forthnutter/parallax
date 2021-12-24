! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors
    namespaces command-line sequences
    strings vectors parallax.propeller.compilerconfig
    parallax.propeller.preprocess ;

IN: parallax.propeller.compilespin

SYMBOL: s_nObjStackPtr
SYMBOL: s_pCompilerData
SYMBOL: s_bFinalCompile
SYMBOL: s_pCompileResultBuffer
SYMBOL: s_compilerConfig
SYMBOL: s_preprocess
!  
: <compilespin> ( pCompilerConfig pLoadFileFunc pFreeFileBufferFunc -- )

    0 s_nObjStackPtr set
    0 s_pCompilerData set
    f s_bFinalCompile set
    0 s_pCompileResultBuffer set

    rot dup [ s_compilerConfig set ] [ drop ] if
 
    s_pFreeFileBufferFunc set
    s_pLoadFileFunc set

    s_pLoadFileFunc get
    s_pFreeFileBufferFunc get
    pp-setfilefunctions

    preprocess new [ s_preprocess set ] keep
    s_compilerConfig get alternatepreprocessormode>>
    pp_init

    s_preprocess get
    "\\'" "{" "}"
    pp_setcomments
;