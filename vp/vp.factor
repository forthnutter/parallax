! visual Propeller Assembler
! Copyright (C) 2022 forthnutter.

USING:  accessors arrays kernel math
    math.functions math.rectangles
    math.trig
    models opengl opengl.demo-support opengl.gl
    sequences
    ui ui.gadgets ui.gadgets.borders ui.gadgets.glass
    ui.gadgets.labels ui.gadgets.packs
    ui.gadgets.tables 
    ui.gestures ;

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

TUPLE: ctable < table { quot initial: [ ] } { val-quot initial: [ ] }
    color-quot column-titles column-alignment actions ;

M: ctable column-titles column-titles>> ;
M: ctable column-alignment column-alignment>> ;
M: ctable row-columns quot>> [ call( a -- b ) ] [ drop f ] if* ;
M: ctable row-value val-quot>> [ call( a -- b ) ] [ drop f ] if* ;
M: ctable row-color color-quot>> [ call( a -- b ) ] [ drop f ] if* ;


: new-ctable ( model class -- table )
    f swap new-table dup >>renderer f <basic> >>actions
    dup actions>> [ set-model ] curry >>action ;

: <ctable> ( model -- table ) ctable new-ctable ;
: <ctable*> ( -- table ) V{ } clone <model> <ctable> ;
: <list> ( column-model -- table ) <ctable> [ 1array ] >>quot ;
: <list*> ( -- table ) V{ } clone <model> <list> ;
: indexed ( table -- table ) f >>val-quot ;


TUPLE: combo-table < ctable spawner ;

M: combo-table handle-gesture
    [ call-next-method drop ] 2keep swap
    T{ button-up } = [
        [ spawner>> ]
        [
            selected-row
            [ swap set-control-value ] [ 2drop ] if
        ]
        [ hide-glass ] tri
    ] [ drop ] if t ;

TUPLE: combobox < label-control table ;

combobox
    H{
        {
            T{ button-down } [ dup table>> over >>spawner <zero-rect> show-glass ]
        }
    } set-gestures

: <combobox> ( options -- combobox )
    [ first [ combobox new-label ] keep
        <basic> >>model
    ] keep
    <basic> combo-table new-ctable
    [ 1array ] >>quot >>table ;


: create-gadgets ( -- gadgets )
    <block-frame>
    <block-gadget>
    add-gadget
    { "first" "second" "third" } <combobox>
    add-gadget
    { 2 2 } <border> ;


MAIN-WINDOW: vp-go { { title "Visual Parallax Assembler" } }
    B create-gadgets >>gadgets ;

