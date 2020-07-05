! This a propeller device lister

USES: kernel io io.serial tserial ;

IN: parallax.propeller.device


TUPLE: device rec mto serial ;




: <device> ( -- device )
  device new ! assign some memory
  0 >>rec ! resource error count
  100 >>mto  ! minimum time out
  ;
