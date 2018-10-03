SCREEN _NEWIMAGE(600, 600, 32)

TYPE circles
    x AS SINGLE
    y AS SINGLE
    radius AS SINGLE
    ratio AS SINGLE
    color AS _UNSIGNED LONG
END TYPE

DIM circles(1 TO 1000) AS circles

_TITLE "Circle drawing"
RANDOMIZE TIMER

DO
    WHILE _MOUSEINPUT: WEND

    IF _MOUSEBUTTON(1) THEN
        IF NOT mouseDown THEN
            mouseDown = -1
            totalCircles = totalCircles + 1
            IF totalCircles > 1000 THEN totalCircles = 1
            mx1 = _MOUSEX
            my1 = _MOUSEY
            mx2 = mx1
            my2 = my1
            circles(totalCircles).color = _RGB32(RND * 255, RND * 255, RND * 255)
        ELSE
            mx2 = _MOUSEX
            my2 = _MOUSEY
        END IF
    ELSE
        mouseDown = false
    END IF

    CLS

    IF mouseDown THEN
        x1 = mx1
        x2 = mx2
        IF x1 > x2 THEN SWAP x1, x2

        y1 = my1
        y2 = my2
        IF y1 > y2 THEN SWAP y1, y2

        circles(totalCircles).x = x1 + (x2 - x1) / 2
        circles(totalCircles).y = y1 + (y2 - y1) / 2
        IF (x2 - x1) > (y2 - y1) THEN
            circles(totalCircles).radius = (x2 - x1) / 2
        ELSE
            circles(totalCircles).radius = (y2 - y1) / 2
        END IF
        circles(totalCircles).ratio = (y2 - y1) / (x2 - x1)
    END IF

    FOR i = 1 TO totalCircles
        CIRCLE (circles(i).x, circles(i).y), circles(i).radius, circles(i).color, , , circles(i).ratio
    NEXT

    _DISPLAY
    _LIMIT 60
LOOP
