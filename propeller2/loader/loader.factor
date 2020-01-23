
! Copyright (C) 2020 forthnutter.
!


USING: math.bitwise make kernel io system formatting semantic-versioning
        io.serial io.streams.duplex io.timeouts tools.continuations accessors
        calendar byte-arrays ;
IN: parallax.propeller2.loader

CONSTANT: version "0.1.0"

: with-serial-port-fix ( serial-port quot -- )
    break
    [ open-serial ] dip
    [ [ stream>> 10 seconds over set-timeout  drop ] keep ] dip
!    [ [ stream>> dup in>> buffer>> 1 >>size drop drop ] keep ] dip
!    [ [ dup serial-fd F_SETFL 0 fcntl drop drop ] keep ] dip
    [ stream>> ] dip
    with-stream ; inline

: loader ( -- )
  vm-version version "Factor %s P2 Loader V%s forthnutter 2020\n" printf
  "/dev/ttyUSB1" 115200 <serial-port>
  [
  break
    "> Prop_Chk 0 0 0 0 " >byte-array write
  ] with-serial-port-fix
;
