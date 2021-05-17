! Copyright (C) 2011 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.dir

TUPLE: dir < model ;

: dir-read ( dir -- data )
   value>> ;

: dir-write ( data dir -- )
   set-model ;

M: dir model-changed
   break
   [ value>> ] dip ! get memory value
   dir-write         ! send it out we may have others
;

: dir-add-connection ( object dir -- )
   add-connection ;


: <dir> ( value -- dira )
   dir new-model ;

