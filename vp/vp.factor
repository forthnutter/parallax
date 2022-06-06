! visual Propeller Assembler
! Copyright (C) 2022 forthnutter.

USING:  accessors kernel math math.functions math.trig
    opengl opengl.demo-support opengl.gl sequences
    ui ui.gadgets ui.gadgets.labels ui.gadgets.packs ;

IN: parallax.vp

TUPLE: block-gadget < gadget ;

: <block-gadget> ( -- gadget )
    block-gadget new ;


TUPLE: block-frame < pack ;

: <block-frame> ( -- gadget )
    block-freame new horizontal >>orientation
    { 512 512 } >>pref-dim ;





: vec>deg ( vec -- deg ) first2 rect> arg rad>deg ;


: block-draw ( block -- )
    dup pos>>
    [
        vel>> vec>deg 0 0 1 glRotated GL_TRIANGLES
        [
            -6.0 4.0 glVertex2f
            -6.0 -4.0 glVertex2f
            8.0 0.0 glVertex2f
        ] do-state
    ] with-translation ;


MAIN-WINDOW: vp-go { { title "Visual Parallax Assembler" } }
    B <block-gadget> >>gadgets ;

