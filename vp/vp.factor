! visual Propeller Assembler
! Copyright (C) 2022 forthnutter.

USING:  accessors arrays kernel math math.functions math.trig
    models opengl opengl.demo-support opengl.gl
    sequences
    ui ui.gadgets ui.gadgets.labels ui.gadgets.packs
    ui.gadgets.tables ;

IN: parallax.vp

TUPLE: multi-model < model important? ;


TUPLE: basic-model < multi-model ;


: <basic> ( value -- model ) basic-model new-model ;


TUPLE: block-gadget < gadget ;

: <block-gadget> ( -- gadget )
    block-gadget new ;


TUPLE: block-frame < pack ;

: <block-frame> ( -- gadget )
    block-frame new horizontal >>orientation
    { 512 512 } >>pref-dim ;

TUPLE: combo-table < table spawner ;

TUPLE: combobox < label-control table ;

: <combobox> ( options -- combobox )
    [ first [ combobox new-label ] keep
        <basic> >>model
    ] keep
    <basic> combo-table new-table
    [ 1array ] >>quot >>table ;




MAIN-WINDOW: vp-go { { title "Visual Parallax Assembler" } }
    B <block-gadget> >>gadgets ;

