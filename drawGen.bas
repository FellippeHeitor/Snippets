$CONSOLE
TYPE vertex
    x AS INTEGER
    y AS INTEGER
END TYPE

DIM SHARED fillR AS INTEGER, fillG AS INTEGER, fillB AS INTEGER
DIM SHARED penR AS INTEGER, penG AS INTEGER, penB AS INTEGER
DIM SHARED screenWidth&, screenHeight&
DIM SHARED theScreen&, newColor~&, shape AS vertex

DO UNTIL _SCREENEXISTS: _LIMIT 1: LOOP
_SCREENMOVE _MIDDLE
_TITLE "DrawGen"

fillR = 255
fillG = 255
fillB = 255
penR = fillR
penG = fillG
penB = fillB

DO
    INPUT "Load image (no file name for blank screen): ", file$
    IF file$ = "" THEN
        DO
            INPUT "Screen dimensions (width, height) = ", screenWidth&, screenHeight&
            IF screenWidth& = 0 OR screenHeight& = 0 THEN
                PRINT "Invalid values."
            END IF
        LOOP UNTIL screenWidth& > 0 AND screenHeight& > 0
        theScreen& = _NEWIMAGE(screenWidth&, screenHeight&, 32)
        SCREEN theScreen&
        EXIT DO
    ELSE
        IF _FILEEXISTS(file$) THEN
            backImage& = _LOADIMAGE(file$, 32)
            IF backImage& < -1 THEN 'load successful
                theScreen& = _NEWIMAGE(_WIDTH(backImage&), _HEIGHT(backImage&), 32)
                SCREEN theScreen&
                EXIT DO
            ELSE
                backImage& = 0
                PRINT "Load failed."
                file$ = ""
            END IF
        ELSE
            PRINT "File not found."
        END IF
    END IF
LOOP

_KEYCLEAR
clearMouseBuffer

drawing$ = "B C" + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " " 'begin with a blind move and white pen

_ECHO "Instructions: --------------------"
_ECHO "- Draw with your mouse to generate a string for the DRAW command."
_ECHO "- Hold Shift to show the original image and activate the color picker."
_ECHO "- While the color picker is on, click with left mouse button to pick PEN color;"
_ECHO "    Click with right mouse button to pick FILL color."
_ECHO "- When you start drawing you begin a shape. Hit ENTER to close the shape."
_ECHO "- To break the shape without closing it, hit B."
_ECHO "- Hit C to show the color mixer."
_ECHO "- Hit Backspace or Ctrl+Z to undo movements."
_ECHO "- Hit Ctrl+C to copy the string to the clipboard."
_ECHO "- Hit Ctrl+V to paste a DRAW string from the clipboard."
_ECHO "- Hit I to swap PEN and FILL colors."
_ECHO "- Hit DELETE to erase the current drawing (cannot be undone)."
_ECHO "- Place the mouse inside a closed area and hit P to paint with the current FILL color."
_ECHO "-----------------------------------"

DO
    _LIMIT 60

    IF _MOUSEINPUT THEN
        IF _MOUSEBUTTON(1) = mb AND _MOUSEBUTTON(2) = mb2 THEN
            DO WHILE _MOUSEINPUT
                IF NOT (_MOUSEBUTTON(1) = mb AND _MOUSEBUTTON(2) = mb2) THEN EXIT DO
            LOOP
        END IF
        mb = _MOUSEBUTTON(1)
        mb2 = _MOUSEBUTTON(2)
        mx = _MOUSEX
        my = _MOUSEY
    END IF
    WHILE _MOUSEINPUT: WEND

    k = _KEYHIT

    IF backImage& < -1 THEN
        _PUTIMAGE (0, 0), backImage&
    ELSE
        CLS
    END IF

    IF NOT (_KEYDOWN(100305) OR _KEYDOWN(100306)) THEN
        ON ERROR GOTO drawError
        DRAW drawing$
        ON ERROR GOTO 0
    END IF

    'current color display
    previewx = 10
    previewy = 10
    previeww = 20
    previewh = 20

    IF NOT (mx >= previewx AND mx <= previewx + previeww AND my >= previewy AND my <= previewy + previewh) THEN
        LINE (previewx, previewy)-STEP(previeww - 1, previewh - 1), _RGB32(0, 0, 0), B
        LINE (previewx + 2, previewy + 2)-STEP(previeww - 5, previewh - 5), _RGB32(penR, penG, penB), BF
        LINE (previewx + 4, previewy + 4)-STEP(previeww - 9, previewh - 9), _RGB32(fillR, fillG, fillB), BF
        LINE (previewx + 4, previewy + 4)-STEP(previeww - 9, previewh - 9), _RGB32(255 - fillR, 255 - fillG, 255 - fillB), B
    END IF

    IF (_KEYDOWN(100303) OR _KEYDOWN(100304)) THEN
        'Hold shift to show original image without the overlay and also show
        'the "color picker".

        t& = _COPYIMAGE(0)
        _SOURCE t&

        newColor~& = POINT(map(_MOUSEX, 0, _WIDTH(0) - 1, 0, _WIDTH - 1), map(_MOUSEY, 0, _HEIGHT(0) - 1, 0, _HEIGHT - 1))
        _SOURCE 0

        _FREEIMAGE t&

        'the color picker
        previewx = mx + 10
        previewy = my + 10
        previeww = 20
        previewh = 20
        IF previewx + previeww > _WIDTH - 1 THEN previewx = _WIDTH - previeww - 1
        IF previewy + previewh > _HEIGHT - 1 THEN previewy = _HEIGHT - previewh - 1

        LINE (previewx, previewy)-STEP(previeww - 1, previewh - 1), _RGB32(255, 255, 255), BF
        LINE (previewx + 2, previewy + 2)-STEP(previeww - 5, previewh - 5), _RGB32(0, 0, 0), BF
        LINE (previewx + 4, previewy + 4)-STEP(previeww - 9, previewh - 9), newColor~&, BF
    ELSEIF backImage& < -1 THEN
        LINE (0, 0)-STEP(_WIDTH, _HEIGHT), _RGBA32(0, 0, 0, 100), BF 'darken the back image
    END IF

    _DISPLAY

    IF mb THEN
        IF (_KEYDOWN(100303) OR _KEYDOWN(100304)) THEN
            pickingColor = -1

            penR = _RED32(newColor~&)
            penG = _GREEN32(newColor~&)
            penB = _BLUE32(newColor~&)

            DO WHILE mb
                WHILE _MOUSEINPUT: WEND
                mb = _MOUSEBUTTON(1)
            LOOP
        ELSEIF (_KEYDOWN(100303) = 0 AND _KEYDOWN(100304) = 0) THEN
            IF usedFillToDraw THEN
                usedFillToDraw = 0
                drawing$ = drawing$ + "B C" + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " "
            END IF
            drawing$ = drawing$ + "M" + LTRIM$(STR$(mx)) + "," + LTRIM$(STR$(my)) + " "

            IF NOT shapeBegin THEN
                shapeBegin = -1
                shape.x = mx
                shape.y = my
            END IF

            DO
                mb = _MOUSEINPUT
                IF _MOUSEX <> mx OR _MOUSEY <> my THEN
                    mx = _MOUSEX
                    my = _MOUSEY
                    drawing$ = drawing$ + "M" + LTRIM$(STR$(mx)) + "," + LTRIM$(STR$(my)) + " "
                    EXIT DO
                END IF
            LOOP WHILE _MOUSEBUTTON(1)
        END IF
    END IF

    IF mb2 THEN
        IF (_KEYDOWN(100303) OR _KEYDOWN(100304)) THEN
            fillR = _RED32(newColor~&)
            fillG = _GREEN32(newColor~&)
            fillB = _BLUE32(newColor~&)

            DO WHILE mb2
                WHILE _MOUSEINPUT: WEND
                mb2 = _MOUSEBUTTON(2)
            LOOP
        ELSEIF (_KEYDOWN(100303) = 0 AND _KEYDOWN(100304) = 0) THEN
            IF NOT usedFillToDraw THEN drawing$ = drawing$ + "B C" + LTRIM$(STR$(_RGB32(fillR, fillG, fillB))) + " "
            drawing$ = drawing$ + "M" + LTRIM$(STR$(mx)) + "," + LTRIM$(STR$(my)) + " "

            IF NOT shapeBegin THEN
                shapeBegin = -1
                shape.x = mx
                shape.y = my
            END IF

            DO
                mb = _MOUSEINPUT
                IF _MOUSEX <> mx OR _MOUSEY <> my THEN
                    mx = _MOUSEX
                    my = _MOUSEY
                    drawing$ = drawing$ + "M" + LTRIM$(STR$(mx)) + "," + LTRIM$(STR$(my)) + " "
                    EXIT DO
                END IF
            LOOP WHILE _MOUSEBUTTON(2)
            usedFillToDraw = -1
        END IF
    END IF

    IF (_KEYDOWN(100303) = 0 AND _KEYDOWN(100304) = 0) THEN
        IF pickingColor THEN
            pickingColor = 0
            drawing$ = drawing$ + "C" + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " B "
            c "New pen color set."
        END IF
    END IF

    IF k = 8 OR (k = ASC("Z") OR k = ASC("z") AND (_KEYDOWN(100305) OR _KEYDOWN(100306))) THEN
        undobyUser = -1
        GOSUB drawError
        undobyUser = 0
    END IF

    IF k = ASC("C") OR k = ASC("c") AND (_KEYDOWN(100305) OR _KEYDOWN(100306)) THEN
        'ctrl+c
        _CLIPBOARD$ = drawing$
        c "Data copied to the clipboard."
    ELSEIF k = ASC("C") OR k = ASC("c") THEN
        IF colorPicker THEN
            drawing$ = drawing$ + "C" + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " B "
            IF usedFillToDraw THEN usedFillToDraw = 0
            c "New pen color set."
        END IF
    END IF

    IF k = ASC("V") OR k = ASC("v") AND (_KEYDOWN(100305) OR _KEYDOWN(100306)) THEN
        'ctrl+v
        IF LEFT$(_CLIPBOARD$, 2) = "B " THEN
            drawing$ = _CLIPBOARD$
            c "Data pasted from the clipboard."
        END IF
    END IF

    IF k = ASC("B") OR k = ASC("b") THEN
        IF RIGHT$(drawing$, 2) <> "B " THEN
            'skip drawing the next line
            drawing$ = drawing$ + "B "
            shapeBegin = 0
            c "Polygon/line interrupted."
        END IF
    END IF

    IF k = ASC("I") OR k = ASC("i") THEN
        'invert pen/fill colors
        SWAP penR, fillR
        SWAP penG, fillG
        SWAP penB, fillB

        drawing$ = drawing$ + "B C" + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " "
        shapeBegin = 0

        c "Pen and fill colors inverted."
    END IF

    IF k = 21248 THEN '(delete)
        drawing$ = "B C" + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " "
        c "Drawing deleted."
    END IF

    IF k = 13 THEN 'enter
        IF shapeBegin THEN
            'close shape
            shapeBegin = 0
            drawing$ = drawing$ + "M" + LTRIM$(STR$(shape.x)) + "," + LTRIM$(STR$(shape.y)) + " B "
            c "Shape closed."
        ELSE
            c "No shape started."
        END IF
    END IF

    IF k = ASC("P") OR k = ASC("p") THEN
        drawing$ = drawing$ + "B M" + LTRIM$(STR$(mx)) + "," + LTRIM$(STR$(my)) + " "
        drawing$ = drawing$ + "P" + LTRIM$(STR$(_RGB32(fillR, fillG, fillB))) + "," + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " "
        drawing$ = drawing$ + "C" + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " B "
        c "Paint applied."
    END IF

    IF d$ <> drawing$ THEN
        'if the drawing has changed, update the console output
        d$ = drawing$
        c d$
    END IF
LOOP

SYSTEM
drawError:
IF LEN(drawing$) > 2 THEN
    FOR i = LEN(drawing$) - 1 TO 1 STEP -1
        IF ASC(drawing$, i) = 32 THEN
            drawing$ = LEFT$(drawing$, i)
            IF drawing$ = "B " THEN drawing$ = drawing$ + "C" + LTRIM$(STR$(_RGB32(penR, penG, penB))) + " "
            EXIT FOR
        END IF
    NEXT
END IF
IF undobyUser THEN c "Last instruction undone.": RETURN
RESUME

SUB c (t$)
    _ECHO t$
END SUB

FUNCTION colorPicker
    DIM pickerScreen AS LONG
    DIM picker AS INTEGER, i AS INTEGER, v AS INTEGER
    DIM y AS INTEGER, shade AS _UNSIGNED LONG, red$
    DIM backupR AS INTEGER, backupG AS INTEGER, backupB AS INTEGER
    DIM backupPenR AS INTEGER, backupPenG AS INTEGER, backupPenB AS INTEGER

    STATIC red AS INTEGER, green AS INTEGER, blue AS INTEGER
    STATIC setup AS _BYTE

    IF NOT setup THEN
        red = fillR
        green = fillG
        blue = fillB
        setup = -1
    END IF

    backupR = fillR
    backupG = fillG
    backupB = fillB
    backupPenR = penR
    backupPenG = penG
    backupPenB = penB

    pickerScreen = _NEWIMAGE(400, 400, 32)
    SCREEN pickerScreen
    _TITLE "Color picker"

    m1$ = "Left click here to set pen color;"
    m2$ = "Right click here to set fill color;"
    m3$ = "Enter to confirm; ESC to canel."
    pwm1 = _PRINTWIDTH(m1$)
    pwm2 = _PRINTWIDTH(m2$)
    pwm3 = _PRINTWIDTH(m3$)

    DO
        IF _MOUSEINPUT THEN
            IF _MOUSEBUTTON(1) = mb AND _MOUSEBUTTON(2) = mb2 THEN
                DO WHILE _MOUSEINPUT
                    IF NOT (_MOUSEBUTTON(1) = mb AND _MOUSEBUTTON(2) = mb2) THEN EXIT DO
                LOOP
            END IF
            mb = _MOUSEBUTTON(1)
            mb2 = _MOUSEBUTTON(2)
            mx = _MOUSEX
            my = _MOUSEY
        END IF
        WHILE _MOUSEINPUT: WEND

        k = _KEYHIT

        CLS

        'current color display
        previewx = 10
        previewy = 10
        previeww = 20
        previewh = 20

        LINE (previewx, previewy)-STEP(previeww - 1, previewh - 1), _RGB32(0, 0, 0), B
        LINE (previewx + 2, previewy + 2)-STEP(previeww - 5, previewh - 5), _RGB32(penR, penG, penB), BF
        LINE (previewx + 4, previewy + 4)-STEP(previeww - 9, previewh - 9), _RGB32(fillR, fillG, fillB), BF
        LINE (previewx + 4, previewy + 4)-STEP(previeww - 9, previewh - 9), _RGB32(255 - fillR, 255 - fillG, 255 - fillB), B

        'draw bars:
        'red
        v = red: y = 40: shade = _RGB32(255, 0, 0)
        GOSUB drawBar

        'green
        v = green: y = 70: shade = _RGB32(0, 255, 0)
        GOSUB drawBar

        'green
        v = blue: y = 100: shade = _RGB32(0, 0, 255)
        GOSUB drawBar

        'result:
        COLOR _RGB32(255, 255, 255)
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH("Result:") / 2, 140), "Result:"
        red$ = "_RGB32(" + LTRIM$(STR$(red)) + ", " + LTRIM$(STR$(green)) + ", " + LTRIM$(STR$(blue)) + ")"
        _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH(red$) / 2, 140 + _FONTHEIGHT), red$
        LINE (20, 180)-STEP(360, 200), _RGB32(255, 255, 255), BF
        LINE (22, 182)-STEP(354, 196), _RGB32(red, green, blue), BF

        COLOR _RGB32(255 - red, 255 - green, 255 - blue), 0
        _PRINTSTRING (200 - pwm1 / 2, 280 - _FONTHEIGHT - _FONTHEIGHT / 2), m1$
        _PRINTSTRING (200 - pwm2 / 2, 280 - _FONTHEIGHT / 2), m2$
        _PRINTSTRING (200 - pwm3 / 2, 280 + _FONTHEIGHT / 2 + _FONTHEIGHT), m3$

        IF k = 27 THEN
            fillR = backupR
            fillG = backupG
            fillB = backupB
            penR = backupPenR
            penG = backupPenG
            penB = backupPenB

            EXIT DO
        ELSEIF k = 13 THEN
            EXIT DO
        END IF

        IF mb THEN
            IF dragging = 0 THEN
                IF mx > 20 AND mx < 380 THEN
                    SELECT CASE my
                        CASE 40 TO 60 'red slider
                            dragging = 1
                        CASE 70 TO 90 'green slider
                            dragging = 2
                        CASE 100 TO 120 'blue slider
                            dragging = 3
                        CASE 182 TO 378 'result
                            colorPicker = -1
                            penR = red
                            penG = green
                            penB = blue
                    END SELECT
                END IF
            END IF
        ELSE
            IF dragging > 0 THEN dragging = 0
        END IF

        IF mb2 THEN
            IF mx > 20 AND mx < 380 THEN
                SELECT CASE my
                    CASE 182 TO 378 'result
                        fillR = red
                        fillG = green
                        fillB = blue
                END SELECT
            END IF
        END IF

        SELECT CASE dragging
            CASE 1
                red = constrain(map(mx, 22, 376, 0, 255), 0, 255)
            CASE 2
                green = constrain(map(mx, 22, 376, 0, 255), 0, 255)
            CASE 3
                blue = constrain(map(mx, 22, 376, 0, 255), 0, 255)
        END SELECT

        _DISPLAY
        _LIMIT 60
    LOOP

    clearMouseBuffer

    SCREEN theScreen&
    _TITLE "DrawGen"
    _FREEIMAGE pickerScreen

    EXIT SUB
    drawBar:
    LINE (20, y)-STEP(360, 20), _RGB32(255, 255, 255), BF
    LINE (22, y + 2)-STEP(355, 16), shade, BF
    picker = map(v, 0, 255, 22, 376)
    FOR i = -6 TO 6
        LINE (picker + i, y + 2)-(picker - i, y + 18), _RGB32(0, 0, 0)
    NEXT
    FOR i = -2 TO 2
        LINE (picker + i, y + 5)-(picker - i, y + 15), _RGB32(150, 150, 150)
    NEXT

    RETURN
END SUB

SUB clearMouseBuffer
    DO
        WHILE _MOUSEINPUT: WEND
    LOOP WHILE _MOUSEBUTTON(1) OR _MOUSEBUTTON(2)
END SUB

'Functions below this line are borrowed from the p5js.bas library
'https://github.com/AshishKingdom/p5js.bas

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

FUNCTION constrain! (n!, low!, high!)
    constrain! = max(min(n!, high!), low!)
END FUNCTION

'Calculate minimum value between two values
FUNCTION min! (a!, b!)
    IF a! < b! THEN min! = a! ELSE min! = b!
END FUNCTION

'Calculate maximum value between two values
FUNCTION max! (a!, b!)
    IF a! > b! THEN max! = a! ELSE max! = b!
END FUNCTION
