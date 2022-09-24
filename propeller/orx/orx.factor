! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.


USING: accessors arrays kernel sequences math models
   vectors tools.continuations ;

IN: parallax.propeller.orx

! orx is used as a dependancey
! for the io section of each cog
! it is here to OR in comming data to the current value
TUPLE: orx < model ;

! generics for read and write
GENERIC: or-read ( orx -- d )
GENERIC: or-write ( d orx -- )


! Just read the value
M: orx or-read
   value>> ;

! lets write
M: orx or-write
    [ or-read bitor ] keep
   set-model ;

! a change is applied by external routine
M: orx model-changed
    break
    [ drop ] dip
    [ 0 ] dip
    [ dependencies>> ] keep
    [ [ value>> bitor ] each ] dip
    set-model
    ;  ! this will change obsevers

: orx-dependency ( dep orx -- )
    add-dependency ;


: orx-activate ( orx -- )
    activate-model ;

! init this object 
: <orx> ( value -- orx )
   orx new-model ;