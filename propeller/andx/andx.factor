! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.andx

! andx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: andx < model ;

! generics for read and write
GENERIC: and-read ( andx -- d )
GENERIC: and-write ( d andx -- )


! Just read the value
M: andx and-read
   value>> ;

! lets write
M: andx and-write
    [ and-read bitor ] keep
   set-model ;

! a change is applied by external routine
M: andx model-changed
   break
   [ value>> ] dip
   and-write ;  ! this will change obsevers



! init this object 
: <andx> ( value -- andx )
   andx new-model ;