OPTION _EXPLICIT

'declarations required by the ui system: ---------------------------------------
CONST True = -1, False = 0

TYPE uiObject
    name AS STRING
    handle AS LONG
    x AS SINGLE
    y AS SINGLE
    w AS INTEGER
    h AS INTEGER
    state AS INTEGER
    color AS _UNSIGNED LONG
    fgColor AS _UNSIGNED LONG
    text AS STRING
END TYPE

REDIM SHARED ui(0) AS uiObject
DIM SHARED mouseDownOn AS INTEGER, uiClicked AS _BYTE, mouseWheel AS INTEGER
DIM SHARED mouseIsDown AS _BYTE, mouseDownX AS INTEGER, mouseDownY AS INTEGER
DIM SHARED mb1 AS _BYTE, mb2 AS _BYTE, mx AS INTEGER, my AS INTEGER
DIM SHARED focus AS INTEGER, i AS INTEGER
'end of declarations required by the ui system. --------------------------------

SCREEN _NEWIMAGE(800, 600, 32)
_PRINTMODE _KEEPBACKGROUND
_CONTROLCHR OFF

'create ui elements
uiReset
i = addUiItem("testlabelbg", _WIDTH - 202, 58, _PRINTWIDTH("  Circles Galore v1.0  ") + 4, _FONTHEIGHT * 2 + 4)
ui(i).color = _RGB32(255)

i = addUiItem("testlabel1", _WIDTH - 200, 60, _PRINTWIDTH("  Circles Galore v1.0  "), _FONTHEIGHT * 2)
ui(i).text = "Circles Galore v1.0"
ui(i).color = _RGB32(80)
ui(i).fgColor = _RGB32(255)


i = addUiItem("testbutton1", _WIDTH - 180, 100, _PRINTWIDTH("  Pause  "), _FONTHEIGHT * 2)
ui(i).text = "Pause"
ui(i).state = True '.state = True to make it clickable
ui(i).color = _RGB32(180)
ui(i).fgColor = _RGB32(80)

i = addUiItem("exitbutton", _WIDTH - 100, 100, _PRINTWIDTH("  Exit  "), _FONTHEIGHT * 2)
ui(i).text = "Exit"
ui(i).state = True '.state = True to make it clickable
ui(i).color = _RGB32(100, 44, 0)
ui(i).fgColor = _RGB32(255)


DIM pause AS _BYTE

DO
    'this would be your simulation's main loop drawing routines -----------------------
    CLS , _RGB32(50)
    IF NOT pause THEN CIRCLE (RND * _WIDTH, RND * _HEIGHT), RND * 500, _RGB32(255 * RND, 255 * RND, 255 * RND)
    'this would be the end of your main loop drawing routines   -----------------------

    'this is the ui routine --------------------
    uiDisplay
    uiCheck
    IF uiClicked THEN
        SELECT CASE ui(mouseDownOn).name
            CASE "testbutton1"
                pause = NOT pause
                IF pause THEN ui(mouseDownOn).text = "Play" ELSE ui(mouseDownOn).text = "Pause"
            CASE "exitbutton"
                SYSTEM
        END SELECT
        uiClicked = False
    END IF
    'the end of the ui routine -----------------

    _DISPLAY
    _LIMIT 60
LOOP

SUB uiCheck
    DIM i AS INTEGER

    mouseWheel = 0
    IF _MOUSEINPUT THEN
        mouseWheel = mouseWheel + _MOUSEWHEEL
        IF _MOUSEBUTTON(1) = mb1 AND _MOUSEBUTTON(2) = mb2 THEN
            DO WHILE _MOUSEINPUT
                mouseWheel = mouseWheel + _MOUSEWHEEL
                IF NOT (_MOUSEBUTTON(1) = mb1 AND _MOUSEBUTTON(2) = mb2) THEN EXIT DO
            LOOP
        END IF
        mb1 = _MOUSEBUTTON(1)
        mb2 = _MOUSEBUTTON(2)
        mx = _MOUSEX
        my = _MOUSEY
    END IF

    focus = 0
    FOR i = UBOUND(ui) TO 1 STEP -1
        IF ui(i).state AND mx > ui(i).x AND mx < ui(i).x + ui(i).w AND my > ui(i).y AND my < ui(i).y + ui(i).h THEN
            focus = i
            EXIT FOR
        END IF
    NEXT

    IF mb1 THEN
        uiClicked = False
        IF NOT mouseIsDown THEN
            mouseDownOn = focus
            mouseIsDown = True
            mouseDownX = mx
            mouseDownY = my
        END IF
    ELSE
        IF mouseIsDown THEN
            IF mouseDownOn THEN
                uiClicked = True
            END IF
        END IF
        mouseIsDown = False
    END IF

END SUB

SUB uiDisplay
    DIM i AS INTEGER, x AS INTEGER, y AS INTEGER
    DIM tempColor AS _UNSIGNED LONG

    CONST hoverIntensity = 30

    FOR i = 1 TO UBOUND(ui)
        IF i = focus THEN _CONTINUE 'draw focused clickable control last
        GOSUB drawIt
    NEXT

    IF focus THEN
        IF ui(focus).state THEN
            i = focus
            GOSUB drawIt
        END IF
    END IF
    EXIT SUB

    drawIt:
    'shadow
    IF ui(i).state THEN
        x = ui(i).x + 4
        y = ui(i).y + 4
        LINE (x, y)-STEP(ui(i).w - 1 + (ABS(i = focus) * 4), ui(i).h - 1 + (ABS(i = focus) * 4)), _RGB32(0, 50), BF
    END IF

    'surface
    IF i = focus AND ui(i).state THEN
        tempColor = _RGB32(_RED32(ui(i).color) + hoverIntensity, _GREEN32(ui(i).color) + hoverIntensity, _BLUE32(ui(i).color) + hoverIntensity)
        LINE (ui(i).x - 2, ui(i).y - 2)-STEP(ui(i).w - 1 + 4, ui(i).h - 1 + 4), tempColor, BF
    ELSE
        LINE (ui(i).x, ui(i).y)-STEP(ui(i).w - 1, ui(i).h - 1), ui(i).color, BF
    END IF

    'custom image
    IF ui(i).handle < -1 THEN
        _PUTIMAGE (ui(i).x, ui(i).y), ui(i).handle
    END IF

    'caption
    IF LEN(ui(i).text) THEN
        x = ui(i).x + ((ui(i).w - _PRINTWIDTH(ui(i).text)) / 2)
        y = ui(i).y + ((ui(i).h - _FONTHEIGHT) / 2)
        IF i = focus AND ui(i).state THEN
            COLOR _RGB32(0, 50)
            _PRINTSTRING (x + 2, y + 2), ui(i).text
        END IF
        COLOR ui(i).fgColor
        _PRINTSTRING (x, y), ui(i).text
    END IF
    RETURN
END SUB

SUB uiReset
    REDIM ui(0) AS uiObject
    uiClicked = False
    mouseDownOn = 0
    focus = 0
END SUB

FUNCTION addUiItem& (name$, x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER)
    DIM i AS LONG
    i = UBOUND(ui) + 1
    REDIM _PRESERVE ui(1 TO i) AS uiObject
    ui(i).name = name$
    ui(i).handle = 0
    ui(i).x = x
    ui(i).y = y
    ui(i).w = w
    ui(i).h = h
    ui(i).state = False
    addUiItem = i
END FUNCTION

