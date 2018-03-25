OPTION _EXPLICIT

TYPE vertex
    x AS SINGLE
    y AS SINGLE
END TYPE

SCREEN _NEWIMAGE(800, 600, 32)
DIM bee AS LONG
bee = _LOADIMAGE("bee-12.jpg")

DIM i AS SINGLE
DO
    WHILE _MOUSEINPUT: WEND
    CLS
    i = map(_MOUSEX, 0, _WIDTH - 1, -90, 90)
    IF _KEYDOWN(100306) THEN i = INT(i)
    PRINT "rotation angle:"; i
    putImage _WIDTH / 2 - _WIDTH(bee) / 2, _HEIGHT / 2 - _HEIGHT(bee) / 2, bee, i
    _DISPLAY
    _LIMIT 30
LOOP

SUB putImage (__x AS SINGLE, __y AS SINGLE, image AS LONG, angleDegrees AS SINGLE)
    DIM i AS LONG

    DIM center AS vertex
    DIM corner(1 TO 4) AS vertex

    center.x = __x + _WIDTH(image) / 2
    center.y = __y + _HEIGHT(image) / 2

    FOR i = 1 TO 4
        SELECT CASE i
            CASE 1
                corner(i).x = __x
                corner(i).y = __y
            CASE 2
                corner(i).x = __x
                corner(i).y = (__y + _HEIGHT(image) - 1)
            CASE 3
                corner(i).x = (__x + _WIDTH(image) - 1)
                corner(i).y = __y
            CASE 4
                corner(i).x = (__x + _WIDTH(image) - 1)
                corner(i).y = (__y + _HEIGHT(image) - 1)
        END SELECT

        rotate corner(i), center, angleDegrees
    NEXT

    _MAPTRIANGLE (0, 0)-(0, _HEIGHT(image) - 1)-(_WIDTH(image) - 1, 0), image TO(corner(1).x, corner(1).y)-(corner(2).x, corner(2).y)-(corner(3).x, corner(3).y)
    _MAPTRIANGLE (0, _HEIGHT(image) - 1)-(_WIDTH(image) - 1, 0)-(_WIDTH(image) - 1, _HEIGHT(image) - 1), image TO(corner(2).x, corner(2).y)-(corner(3).x, corner(3).y)-(corner(4).x, corner(4).y)
END SUB

SUB rotate (p AS vertex, center AS vertex, angleDegrees AS SINGLE)
    'as seen on https://stackoverflow.com/questions/2259476/rotating-a-point-about-another-point-2d
    DIM s AS SINGLE, c AS SINGLE
    DIM newP AS vertex
    DIM angle AS SINGLE

    angle = _D2R(angleDegrees)

    s = SIN(angle)
    c = COS(angle)

    p.x = p.x - center.x
    p.y = p.y - center.y

    newP.x = p.x * c - p.y * s
    newP.y = p.x * s + p.y * c

    p.x = newP.x + center.x
    p.y = newP.y + center.y
END SUB

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

