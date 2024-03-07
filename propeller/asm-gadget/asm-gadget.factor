!




USING: accessors arrays kernel literals system
    tools.continuations
    ui ui.commands ui.gadgets ui.gadgets.labels
    ui.gadgets.menus
    ui.gadgets.toolbar ui.gadgets.tracks ui.gestures
    ui.tools.common ;


IN: parallax.propeller.asm-gadget


TUPLE: asm-gadget < gadget quit? windowed? ;


: com-back ( browser -- ) drop ;
: com-forward ( browser -- ) drop ;
: com-home ( browser -- ) drop ;
: browser-help ( -- ) ;
: glossary ( -- ) ;

asm-gadget "toolbar" f 
{
    { T{ key-down f ${ os macosx? M+ A+ ? } "LEFT" } com-back }
    { T{ key-down f ${ os macosx? M+ A+ ? } "RIGHT" } com-forward }
    { T{ key-down f ${ os macosx? M+ A+ ? } "HOME" } com-home }
    { T{ key-down f f "F1" } browser-help }
    { T{ key-down f ${ os macosx? M+ A+ ? } "F1" } glossary }
} define-command-map




asm-gadget H{
    { T{ key-down f f "ESC" }
        [
            t >>quit? dup windowed?>>
            [ close-window ] [ drop ] if
        ]
    }
} set-gestures

M: asm-gadget pref-dim* drop { 256 256 } ;

: <asm-gadget> ( -- gadget )
    break
    asm-gadget new dup

    ! "test" <label>
    ! "test1" <label> 2array
     <toolbar> 
    add-gadget
    f >>quit? ;


: run-asm ( -- )
    [ <asm-gadget> t >>windowed? "test" open-window  ] with-ui ;
