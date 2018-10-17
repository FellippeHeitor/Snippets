SCREEN _NEWIMAGE(800, 600, 32)
DO
    WHILE _MOUSEINPUT: WEND

    CLS , _RGB32(51, 51, 51)

    'the shadow being cast... sort of
    shadow~& = _RGBA32(0, 0, 0, map(dist(_MOUSEX, _MOUSEY, _WIDTH / 2, _HEIGHT / 2), 0, _WIDTH / 1.5, 255, 0))
    FOR i = 60 TO map(dist(_MOUSEX, _MOUSEY, _WIDTH / 2, _HEIGHT / 2), 0, _WIDTH / 1.5, 60, 512) STEP 5
        CircleFill _WIDTH / 2 - (_MOUSEX - _WIDTH / 2), _HEIGHT / 2 - (_MOUSEY - _HEIGHT / 2), i, shadow~&
    NEXT

    'the object being lit
    CircleFill _WIDTH / 2, _HEIGHT / 2, 60, _RGB32(255, 255, 255)

    'Light source is controlled by mouse
    FOR i = 60 TO 31 STEP -1
        CircleFill _MOUSEX, _MOUSEY, i, _RGBA32(255, 255, 150, 5)
    NEXT
    CircleFill _MOUSEX, _MOUSEY, 30, _RGB32(255, 255, 255)

    _DISPLAY
    _LIMIT 30
LOOP

SUB CircleFill (CX AS LONG, CY AS LONG, R AS LONG, C AS _UNSIGNED LONG)
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

FUNCTION dist! (x1!, y1!, x2!, y2!)
    dist! = SQR((x2! - x1!) ^ 2 + (y2! - y1!) ^ 2)
END FUNCTION

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

