! Copyright (C) 2022 Joseph L Moschini.
! See http://factorcode.org/license.txt for BSD license.
!
USING: accessors arrays kernel sequences models vectors tools.continuations ;

IN: parallax.propeller.cogs.cog.vcfgx

TUPLE: vcfgx < model ;





! vcfg is basically a model
: <vcfgx> ( value -- par )
   vcfgx new-model ;