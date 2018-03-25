SCREEN _NEWIMAGE(800, 400, 32)
kitten = _LOADIMAGE("kitten.png")
newKitten = _COPYIMAGE(kitten)
_SOURCE kitten
factor = 1
COLOR , 0
DO
    _PUTIMAGE (0, 0), kitten
    _PRINTSTRING (0, 0), "Factor =" + STR$(factor)
    _DEST newKitten
    FOR i = 0 TO _WIDTH(kitten) - 1
        FOR j = 0 TO _HEIGHT(kitten) - 1
            c~& = POINT(i, j)
            r = _RED32(c~&)
            g = _GREEN32(c~&)
            b = _BLUE32(c~&)

            r2% = _ROUND(factor * r / 255) * (255 / factor)
            g2% = _ROUND(factor * g / 255) * (255 / factor)
            b2% = _ROUND(factor * b / 255) * (255 / factor)

            PSET (i, j), _RGB32(r2%, g2%, b2%)
        NEXT
    NEXT
    _DEST _DISPLAY
    _PUTIMAGE (400, 0), newKitten
    DO
        k& = _KEYHIT
        IF _KEYDOWN(100306) THEN
            IF k& = 19200 THEN factor = 1: EXIT DO
            IF k& = 19712 THEN factor = 255: EXIT DO
        ELSE
            IF k& = 19200 AND factor > 1 THEN factor = factor - 1: EXIT DO
            IF k& = 19712 AND factor < 255 THEN factor = factor + 1: EXIT DO
        END IF
        _DISPLAY
        _LIMIT 30
    LOOP
LOOP

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

