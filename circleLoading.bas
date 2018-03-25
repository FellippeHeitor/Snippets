SCREEN _NEWIMAGE(400, 400, 32)

angle = 0
r = 100
DO
    angle = angle + _PI(.1)
    IF angle > _PI(2) THEN angle = angle - _PI(2)

    LINE (0, 0)-(_WIDTH, _HEIGHT), _RGBA32(0, 0, 0, 40), BF
    _PRINTSTRING (_WIDTH / 2 - _PRINTWIDTH("Loading...") / 2, _HEIGHT / 2 - _FONTHEIGHT / 2), "Loading..."
    CircleFill _WIDTH / 2 + COS(angle + i) * r, _HEIGHT / 2 + SIN(angle + i) * r, 15, _RGB32(255, 255, 255)
    _DISPLAY
    _LIMIT 15
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


