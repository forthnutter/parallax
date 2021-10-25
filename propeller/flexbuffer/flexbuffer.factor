! Copyright (C) 2021 forthnutter.
!

USING: math math.bitwise make kernel literals accessors namespaces command-line sequences
        strings vectors parallax.propeller.compilerconfig  ;
IN: parallax.propeller.compilespin


TUPLE: fexbuf data len space growsize ;


: <flexbuffer> ( gs -- fb )
    flexbuf new
    f >>data 
    0 >>len
    0 >>space
    swap >>growsize
;


