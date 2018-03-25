OPTION _EXPLICIT

DIM testImage&, totalColors%, row AS INTEGER, col AS INTEGER, i AS INTEGER

SCREEN _NEWIMAGE(800, 600, 256)
_FONT 8
testImage& = loadImage256(COMMAND$, totalColors%)
IF testImage& < -1 THEN
    IF _WIDTH(testImage&) < _WIDTH THEN
        _PUTIMAGE (_WIDTH - _WIDTH(testImage&), 0), testImage& 'place to the right
    ELSE
        _PUTIMAGE , testImage& 'stretch
    END IF
    PRINT "total colors: "; totalColors%
    _COPYPALETTE testImage&, _DEST
ELSE
    PRINT "Load failed"
    END
END IF

'show color palette indexes:
row = 2
col = 1
FOR i = 0 TO totalColors%
    row = row + 1
    IF row > ((_HEIGHT / _FONTHEIGHT) - 2) THEN row = 3: col = col + 10
    LOCATE row, col
    COLOR i: PRINT i
NEXT
END

FUNCTION loadImage256& (file$, totalColors AS INTEGER)
    IF NOT _FILEEXISTS(file$) THEN EXIT FUNCTION

    DIM prevDest AS LONG, prevSource AS LONG
    DIM tempImage AS LONG, outputImage AS LONG
    DIM i AS INTEGER, j AS INTEGER, k AS INTEGER
    DIM c AS _UNSIGNED LONG
    DIM found AS _BYTE, index AS INTEGER

    tempImage = _LOADIMAGE(file$, 32)
    IF tempImage >= -1 THEN EXIT FUNCTION
    outputImage = _NEWIMAGE(_WIDTH(tempImage), _HEIGHT(tempImage), 256)

    prevDest = _DEST
    prevSource = _SOURCE

    _SOURCE tempImage
    _DEST outputImage

    DIM imgPalette(256) AS _UNSIGNED LONG
    FOR i = 0 TO _WIDTH(tempImage) - 1
        FOR j = 0 TO _HEIGHT(tempImage) - 1
            c = POINT(i, j)

            found = 0
            index = 0
            FOR k = 1 TO 256
                IF imgPalette(k) = c THEN
                    found = -1
                    index = k
                    EXIT FOR
                END IF
            NEXT

            IF NOT found THEN
                totalColors = totalColors + 1
                IF totalColors <= 256 THEN
                    index = totalColors
                    imgPalette(totalColors) = c
                ELSE
                    'this image contains more than 256-colors
                    _FREEIMAGE tempImage
                    _FREEIMAGE outputImage
                    totalColors = 0
                    EXIT FUNCTION
                END IF
            END IF

            IF index > 0 THEN
                PSET (i, j), index - 1
                _PALETTECOLOR index - 1, c
            END IF
        NEXT
    NEXT

    _DEST prevDest
    _SOURCE prevSource

    _FREEIMAGE tempImage
    totalColors = totalColors - 1
    loadImage256& = outputImage
END FUNCTION
