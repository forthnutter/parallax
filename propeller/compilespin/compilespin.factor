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
SYMBOL: cs_filename
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


: CompileSpin ( pFilename -- v )
    cs_filename set

    s_compilerConfig get bFileTreeOutputOnly>>
    [
        cs_filename get print
    ] when

    s_compilerConfig get bUnusedMethodElimination>>
    [
        InitUnusedMethodData();
    ] when

    int nOriginalSize = 0;

restart_compile:
    s_pCompilerData = InitStruct();
    s_pCompilerData->bUnusedMethodElimination = s_compilerConfig.bUnusedMethodElimination;
    s_pCompilerData->bFinalCompile = s_bFinalCompile;

    s_pCompilerData->list = new char[ListLimit];
    s_pCompilerData->list_limit = ListLimit;
    memset(s_pCompilerData->list, 0, ListLimit);

    if (s_compilerConfig.bDocMode && !s_compilerConfig.bDATonly)
    {
        s_pCompilerData->doc = new char[DocLimit];
        s_pCompilerData->doc_limit = DocLimit;
        memset(s_pCompilerData->doc, 0, DocLimit);
    }
    else
    {
        s_pCompilerData->doc = 0;
        s_pCompilerData->doc_limit = 0;
    }
    s_pCompilerData->bDATonly = s_compilerConfig.bDATonly;
    s_pCompilerData->bBinary = s_compilerConfig.bBinary;
    s_pCompilerData->eeprom_size = s_compilerConfig.eeprom_size;

    // allocate space for obj based on eeprom size command line option
    s_pCompilerData->obj_limit = s_compilerConfig.eeprom_size > min_obj_limit ? s_compilerConfig.eeprom_size : min_obj_limit;
    s_pCompilerData->obj = new unsigned char[s_pCompilerData->obj_limit];

    // copy filename into obj_title, and chop off the .spin
    strcpy(s_pCompilerData->obj_title, pFilename);
    char* pExtension = strstr(&s_pCompilerData->obj_title[0], ".spin");
    if (pExtension != 0)
    {
        *pExtension = 0;
    }

    int nCompileIndex = 0;
    if (!CompileRecursively(pFilename, nCompileIndex, 0))
    {
        return 0;
    }

    if (!s_compilerConfig.bQuiet)
    {
        // only do this if UME is off or if it's the final compile when UME is on
        if (!s_compilerConfig.bUnusedMethodElimination || s_bFinalCompile)
        {
            printf("Done.\n");
        }
    }

    if (!s_compilerConfig.bFileTreeOutputOnly && !s_compilerConfig.bFileListOutputOnly && !s_compilerConfig.bDumpSymbols)
    {
        if (!s_bFinalCompile && s_compilerConfig.bUnusedMethodElimination)
        {
            nOriginalSize = s_pCompilerData->psize;
            FindUnusedMethods(s_pCompilerData);
            s_bFinalCompile = true;
            CleanupMemory(false);
            goto restart_compile;
        }
        int bufferSize = 0;
        if (!ComposeRAM(&s_pCompileResultBuffer, bufferSize))
        {
            return 0;
        }

        if (!s_compilerConfig.bQuiet)
        {
            if (s_compilerConfig.bUnusedMethodElimination)
            {
                printf("Unused Method Elimination:\n");
                if ((nOriginalSize - s_pCompilerData->psize) > 0)
                {
                    if (s_compilerConfig.bVerbose)
                    {
                        if (s_pCompilerData->unused_obj_files)
                        {
                            printf("Unused Objects:\n");
                            for(int i = 0; i < s_pCompilerData->unused_obj_files; i++)
                            {
                                printf("%s\n", &(s_pCompilerData->obj_unused[i<<8]));
                            }
                        }
                        if (s_pCompilerData->unused_methods)
                        {
                            printf("Unused Methods:\n");
                            for(int i = 0; i < s_pCompilerData->unused_methods; i++)
                            {
                                printf("%s\n", &(s_pCompilerData->method_unused[i*symbol_limit]));
                            }
                        }
                        if (s_pCompilerData->unused_methods || s_pCompilerData->unused_obj_files)
                        {
                            printf("---------------\n");
                        }
                    }
                    printf("%5d methods removed\n%5d objects removed\n%5d bytes saved\n", s_pCompilerData->unused_methods, s_pCompilerData->unused_obj_files,  nOriginalSize - s_pCompilerData->psize );
                }
                else
                {
                    printf("Nothing removed.\n");
                }
                printf("--------------------------\n");
            }
            printf("Program size is %d bytes\n", bufferSize);
        }
        *pnResultLength = bufferSize;
    }

    if (s_compilerConfig.bDumpSymbols)
    {
        DumpSymbols();
    }

    if (s_compilerConfig.bVerbose && !s_compilerConfig.bQuiet && !s_compilerConfig.bDATonly)
    {
        DumpList();
    }

    if (s_compilerConfig.bDocMode && s_compilerConfig.bVerbose && !s_compilerConfig.bQuiet && !s_compilerConfig.bDATonly)
    {
        DumpDoc();
    }

    return s_pCompileResultBuffer;
}
