CONST True = -1, False = NOT True

TYPE Vector
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Scanner
    pos AS Vector
    settled AS _BYTE
END TYPE

DECLARE LIBRARY "falcon"
    SUB uprint_extra (BYVAL x&, BYVAL y&, BYVAL chars%&, BYVAL length%&, BYVAL kern&, BYVAL do_render&, txt_width&, BYVAL charpos%&, charcount&, BYVAL colour~&, BYVAL max_width&)
    FUNCTION uprintwidth (chars$, BYVAL txt_len&, BYVAL max_width&)
    FUNCTION uheight& ()
END DECLARE

CONST Resolution = 100
CONST TheWidth = 600
CONST TheHeight = 300

DIM ScanPoints(1 TO Resolution) AS Scanner
DIM TotalPoints AS LONG
REDIM Points(TheWidth, TheHeight) AS _BYTE
REDIM SHARED ThisLineChars(0) AS LONG

INPUT "Text (default=QB64): ", text$
IF text$ = "" THEN text$ = "QB64"

SCREEN _NEWIMAGE(TheWidth, TheHeight, 32)

'Find the best font size to fit the text$ in the screen
FontSize = 250
DO
    IF FontSize <= 0 THEN END
    IF font& > 0 THEN _FONT 16: _FREEFONT font&
    font& = _LOADFONT("cyberbit.ttf", FontSize)
    _FONT font&
    IF PrintWidth(text$) < _WIDTH THEN EXIT DO
    FontSize = FontSize - 2
LOOP

TextX = _WIDTH / 2 - PrintWidth(text$) / 2
TextY = _HEIGHT / 2 - uheight / 2

CLS , _RGB32(51, 51, 51)
COLOR _RGB32(255, 255, 255)

'Scan the word and mark the glyph boundaries
FOR ScanPass = 1 TO 2
    ScanDone = False
    xStep = 0
    yStep = 0
    ERASE ScanPoints
    SELECT CASE ScanPass
        CASE 1 'down
            yStep = 1
            FOR i = 1 TO Resolution
                ScanPoints(i).pos.x = ((_WIDTH / Resolution) * i)
                ScanPoints(i).pos.y = 0
            NEXT
            vRes = 1
        CASE 2 'right
            xStep = 1
            FOR i = 1 TO Resolution / 2
                ScanPoints(i).pos.x = 0
                ScanPoints(i).pos.y = ((_HEIGHT / (Resolution / 2)) * i)
            NEXT
            vRes = 2
    END SELECT
    DO
        CLS , _RGB32(51, 51, 51)
        COLOR _RGB32(255, 255, 255)
        PrintString TextX, TextY, text$
        FOR i = 1 TO Resolution / vRes
            ScanPoints(i).pos.y = ScanPoints(i).pos.y + yStep
            ScanPoints(i).pos.x = ScanPoints(i).pos.x + xStep
            IF NOT ScanPoints(i).settled THEN
                IF POINT(ScanPoints(i).pos.x, ScanPoints(i).pos.y) = _RGB32(255, 255, 255) THEN
                    ScanPoints(i).settled = True
                    IF NOT Points(ScanPoints(i).pos.x, ScanPoints(i).pos.y) THEN
                        TotalPoints = TotalPoints + 1
                        Points(ScanPoints(i).pos.x, ScanPoints(i).pos.y) = True
                    END IF
                END IF
            ELSE
                IF POINT(ScanPoints(i).pos.x, ScanPoints(i).pos.y) <> _RGB32(255, 255, 255) THEN
                    ScanPoints(i).settled = False
                    IF NOT Points(ScanPoints(i).pos.x, ScanPoints(i).pos.y) THEN
                        TotalPoints = TotalPoints + 1
                        Points(ScanPoints(i).pos.x, ScanPoints(i).pos.y) = True
                    END IF
                END IF
            END IF
            PSET (ScanPoints(i).pos.x, ScanPoints(i).pos.y), _RGB32(255, 0, 255)
        NEXT

        '(mere eye candy) draw a trail of fading dots where the scanner
        'light has passed:
        FOR i = 1 TO Resolution / vRes
            IF NOT ScanPoints(i).settled THEN
                a = 255
                SELECT CASE ScanPass
                    CASE 1
                        FOR y = ScanPoints(i).pos.y TO 0 STEP -1
                            PSET (ScanPoints(i).pos.x, y), _RGBA32(255, 0, 255, a)
                            a = a - 2
                            IF a < 0 THEN EXIT FOR
                        NEXT y
                    CASE 2
                        FOR x = ScanPoints(i).pos.x TO 0 STEP -1
                            PSET (x, ScanPoints(i).pos.y), _RGBA32(255, 0, 255, a)
                            a = a - 2
                            IF a < 0 THEN EXIT FOR
                        NEXT x
                END SELECT
            END IF
        NEXT

        COLOR _RGB32(0, 0, 0)
        PrintString TextX, TextY, text$

        FOR ix = 0 TO _WIDTH
            FOR iy = 0 TO _HEIGHT
                IF Points(ix, iy) THEN CircleFill ix, iy, 1, _RGB32(0, 255, 255)
            NEXT
        NEXT

        _DISPLAY

        SELECT CASE ScanPass
            CASE 1: IF ScanPoints(1).pos.y > _HEIGHT + _HEIGHT / 4 THEN ScanDone = True
            CASE 2: IF ScanPoints(1).pos.x > _WIDTH + _WIDTH / 4 THEN ScanDone = True
        END SELECT

        IF _KEYHIT = 27 THEN EXIT FOR
    LOOP UNTIL ScanDone
NEXT

'Final display of the scanned dots:
CLS
TheData$ = "'" + text$ + CHR$(10) + "DATA " + STR$(TotalPoints) + CHR$(10)
tData$ = "DATA "
FOR ix = 0 TO _WIDTH
    FOR iy = 0 TO _HEIGHT
        IF Points(ix, iy) THEN
            CircleFill ix, iy, 1, _RGB32(0, 255, 255)
            IF LEN(tData$) > 5 THEN tData$ = tData$ + ","
            tData$ = tData$ + STR$(ix) + "," + STR$(iy)
            IF LEN(tData$) > 70 THEN
                TheData$ = TheData$ + tData$ + CHR$(10)
                tData$ = "DATA "
            END IF
        END IF
    NEXT
NEXT
TheData$ = TheData$ + tData$
_CLIPBOARD$ = TheData$
_FONT 16
COLOR _RGB32(255, 255, 255)
PRINT TotalPoints; "points"
_DISPLAY

SLEEP
SYSTEM

SUB PrintString (Left AS INTEGER, Top AS INTEGER, Text$)
    DIM LastRenderedCharCount AS LONG
    Utf$ = Text$

    REDIM ThisLineChars(LEN(Utf$)) AS LONG

    uprint_extra Left, Top, _OFFSET(Utf$), LEN(Utf$), True, True, LastRenderedLineWidth, _OFFSET(ThisLineChars()), LastRenderedCharCount, _DEFAULTCOLOR, 0
    REDIM _PRESERVE ThisLineChars(LastRenderedCharCount) AS LONG
END SUB

FUNCTION PrintWidth& (Text$)
    PrintWidth& = uprintwidth(Text$, LEN(Text$), 0)
END FUNCTION

SUB CircleFill (CX AS LONG, CY AS LONG, R AS LONG, C AS LONG)
    'This sub from here: http://www.qb64.net/forum/index.php?topic=1848.msg17254#msg17254
    DIM Radius AS LONG
    DIM RadiusError AS LONG
    DIM X AS LONG
    DIM Y AS LONG

    Radius = ABS(R)
    RadiusError = -Radius
    X = Radius
    Y = 0

    IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB

    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
    LINE (CX - X, CY)-(CX + X, CY), C, BF

    WHILE X > Y

        RadiusError = RadiusError + Y * 2 + 1

        IF RadiusError >= 0 THEN

            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            END IF

            X = X - 1
            RadiusError = RadiusError - X * 2

        END IF

        Y = Y + 1

        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF

    WEND
END SUB

