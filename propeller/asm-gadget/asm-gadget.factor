!




USING: accessors kernel ui ui.gadgets ui.gestures ;


IN: parallax.propeller.asm-gadget


TUPLE: asm-gadget < gadget quit? windowed? ;

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
    asm-gadget new f >>quit? ;


: run-asm ( -- )
    [ <asm-gadget> t >>windowed? "test" open-window  ] with-ui ;
