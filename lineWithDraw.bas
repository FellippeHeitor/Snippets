CONST false = 0, true = NOT false

DIM x1, y1, x2, y2
DIM mouseDown AS _BYTE
DIM totalDots AS INTEGER
DIM thickness AS INTEGER

thickness = 10

SCREEN _NEWIMAGE(800, 600, 32)

DO
    WHILE _MOUSEINPUT: thickness = thickness + _MOUSEWHEEL: WEND

    IF thickness < 1 THEN thickness = 1

    IF _MOUSEBUTTON(1) THEN
        IF NOT mouseDown THEN
            mouseDown = true
            totalDots = totalDots + 1
            IF totalDots > 2 THEN totalDots = 1
            SELECT CASE totalDots
                CASE 1
                    x1 = _MOUSEX
                    y1 = _MOUSEY
                CASE 2
                    x2 = _MOUSEX
                    y2 = _MOUSEY
            END SELECT
        END IF
    ELSE
        mouseDown = false
    END IF

    CLS
    PRINT "Click to set the initial line coordinate,"
    PRINT "click again to set the final line coordinate."
    PRINT "Use the mousewheel to make the line thicker/thinner."
    PRINT "Current thickness:"; thickness

    IF totalDots = 1 THEN
        PSET (x1, y1)
    ELSE
        thickLine x1, y1, x2, y2, thickness
    END IF
    _DISPLAY
    _LIMIT 30
LOOP

SUB thickLine (x1!, y1!, x2!, y2!, lineWidth%)
    DIM angle%, distance%, halfThickness%
    angle% = INT(_R2D(_ATAN2(y2! - y1!, x2! - x1!)))
    distance% = _HYPOT((x2! - x1!), (y2! - y1!))
    halfThickness% = lineWidth% / 2
    IF halfThickness% < 1 THEN halfThickness% = 1
    IF halfThickness% = 1 THEN
        DRAW "bm" + STR$(x1!) + "," + STR$(y1!) + " TA" + STR$(-angle%) + " R" + STR$(distance%)
    ELSE
        DRAW "bm" + STR$(x1!) + "," + STR$(y1!) + " TA" + STR$(-angle%) + "U" + STR$(halfThickness%) + " R" + STR$(distance%) + "D" + STR$(halfThickness% * 2) + " L" + STR$(distance%) + "U" + STR$(halfThickness%) + " B R" + STR$(distance% / 2) + "P" + STR$(_DEFAULTCOLOR) + "," + STR$(_DEFAULTCOLOR)
    END IF
END SUB
