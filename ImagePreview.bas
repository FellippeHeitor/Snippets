CONST true = -1, false = NOT true

DIM i AS LONG, j AS LONG, k AS LONG, stretched AS _BYTE

_TITLE "Image Preview"

'count total numbered images in folder
DO
    IF _FILEEXISTS(LTRIM$(STR$(i + 1)) + ".jpg") THEN
        i = i + 1
    ELSE
        EXIT DO
    END IF
LOOP

IF i = 0 THEN
    PRINT "No images found."
    END
END IF

PRINT i; "images found. Loading..."

DIM Image(1 TO i) AS LONG
FOR j = 1 TO i
    Image(j) = _LOADIMAGE(LTRIM$(STR$(j)) + ".jpg", 32)
NEXT

SCREEN _NEWIMAGE(1000, 800, 32)
PRINT "Done."

i = 1
stretched = true
DO
    k = _KEYHIT

    SELECT CASE k
        CASE 19712 'right - next image
            i = i + ABS(i < UBOUND(Image))
        CASE 19200 'left - previous image
            i = i + (i > 1)
        CASE 27
            SYSTEM
        CASE 83, 115
            stretched = NOT stretched
    END SELECT

    CLS
    IF stretched THEN
        _PUTIMAGE , Image(i)
    ELSE
        IF _WIDTH(Image(i)) > _HEIGHT(Image(i)) THEN
            DIM newHeight AS INTEGER
            newHeight = (_HEIGHT(Image(i)) / _WIDTH(Image(i))) * _WIDTH(_DISPLAY)
            _PUTIMAGE (0, _HEIGHT / 2 - newHeight / 2)-STEP(_WIDTH - 1, newHeight), Image(i)
        ELSEIF _WIDTH(Image(i)) < _HEIGHT(Image(i)) OR _WIDTH(Image(i)) = _HEIGHT(Image(i)) THEN
            DIM newWidth AS INTEGER
            newWidth = (_HEIGHT(Image(i)) / _WIDTH(Image(i))) * _HEIGHT(_DISPLAY)
            _PUTIMAGE (_WIDTH / 2 - newWidth / 2, 0)-STEP(newWidth, _HEIGHT - 1), Image(i)
        END IF
    END IF

    PRINT "left/right keys to go to next or previous image"
    PRINT "stretch:";
    IF stretched THEN PRINT "on"; ELSE PRINT "off";
    PRINT " (s to toggle)"
    PRINT "esc to quit"
    PRINT "image"; i; "of"; UBOUND(image)
    PRINT "original size:"; _WIDTH(Image(i)); ","; _HEIGHT(Image(i))
    IF NOT stretched THEN
        PRINT "scaled size:";
        IF _WIDTH(Image(i)) > _HEIGHT(Image(i)) THEN
            PRINT _WIDTH; ","; newHeight
        ELSEIF _WIDTH(Image(i)) < _HEIGHT(Image(i)) OR _WIDTH(Image(i)) = _HEIGHT(Image(i)) THEN
            PRINT newWidth; ","; _HEIGHT
        END IF
    END IF
    _DISPLAY
    _LIMIT 30
LOOP
