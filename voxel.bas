OPTION _EXPLICIT

CONST true = -1, false = NOT true

TYPE newVoxel
    x AS SINGLE
    y AS SINGLE
    r AS _UNSIGNED _BYTE
    g AS _UNSIGNED _BYTE
    b AS _UNSIGNED _BYTE
    image AS LONG
END TYPE

DIM SHARED voxelSize AS SINGLE
DIM SHARED totalVoxels AS LONG, i AS LONG
DIM canvas&, mouseDown AS _BYTE

voxelSize = 100
totalVoxels = 0

canvas& = _NEWIMAGE(600, 600, 32)
SCREEN canvas&

_MOUSEHIDE

DIM voxel(1000) AS newVoxel
DIM wireFrameVoxel AS newVoxel

wireFrameVoxel.r = 255
wireFrameVoxel.g = 255
wireFrameVoxel.b = 255

RANDOMIZE TIMER

CONST div = 3.4
CONST divx = 4
DO
    CLS

    WHILE _MOUSEINPUT: WEND
    IF _MOUSEBUTTON(1) THEN
        IF NOT mouseDown THEN
            mouseDown = true
            totalVoxels = totalVoxels + 1
            IF totalVoxels <= UBOUND(voxel) THEN
                voxel(totalVoxels).x = INT(_MOUSEX / (voxelSize / divx)) * (voxelSize / divx)
                voxel(totalVoxels).y = INT(_MOUSEY / (voxelSize / div)) * (voxelSize / div)
                voxel(totalVoxels).r = RND * 255
                voxel(totalVoxels).g = RND * 255
                voxel(totalVoxels).b = RND * 255
            END IF
        END IF
    ELSE
        mouseDown = false
    END IF

    FOR i = 1 TO totalVoxels
        drawVoxel voxel(i), true
    NEXT

    wireFrameVoxel.x = INT(_MOUSEX / (voxelSize / divx)) * (voxelSize / divx)
    wireFrameVoxel.y = INT(_MOUSEY / (voxelSize / div)) * (voxelSize / div)
    drawVoxel wireFrameVoxel, false

    PRINT INT(_MOUSEX / (voxelSize / 2))
    PRINT INT(_MOUSEY / (voxelSize / 2))

    DIM k AS LONG, b$
    k = _KEYHIT
    IF k = 27 THEN totalVoxels = 0
    IF k = 8 THEN totalVoxels = totalVoxels + (totalVoxels > 0)
    IF (k = 67 OR k = 99) AND (_KEYDOWN(100306) OR _KEYDOWN(100305)) THEN
        b$ = ""
        FOR i = 1 TO totalVoxels
            b$ = b$ + "DATA " + STR$(voxel(i).x) + "," + STR$(voxel(i).y) + CHR$(10)
        NEXT
        _CLIPBOARD$ = b$
    END IF

    _DISPLAY
    _LIMIT 30
LOOP

SUB drawVoxel (this AS newVoxel, fill AS _BYTE)
    DIM x AS SINGLE, y AS SINGLE
    DIM top AS SINGLE, leftSide AS SINGLE

    IF this.image = 0 THEN
        DIM tempImage&, previousDest&
        tempImage& = _NEWIMAGE(voxelSize + 1, voxelSize * 1.15, 32)
        previousDest& = _DEST
        _DEST tempImage&

        x = _WIDTH / 2
        y = 0

        COLOR _RGB32(this.r, this.g, this.b)
        LINE (x, y)-STEP(-(voxelSize / 2), voxelSize / 4)
        LINE STEP(0, 0)-STEP((voxelSize / 2), voxelSize / 4)
        LINE STEP(0, 0)-STEP((voxelSize / 2), -(voxelSize / 4))
        LINE STEP(0, 0)-STEP(-(voxelSize / 2), -(voxelSize / 4))
        LINE (x - (voxelSize / 2), y + (voxelSize / 4))-STEP(0, (voxelSize * 0.625))
        LINE STEP(0, 0)-STEP((voxelSize / 2), (voxelSize / 4))
        LINE (x, y + (voxelSize / 2))-STEP(0, (voxelSize * 0.625))
        LINE (x + (voxelSize / 2), y + (voxelSize / 4))-STEP(0, (voxelSize * 0.625))
        LINE STEP(0, 0)-STEP(-(voxelSize / 2), (voxelSize / 4))

        IF fill THEN
            top = .8
            PAINT (x, y + (voxelSize / 4)), _RGB32(this.r * top, this.g * top, this.b * top), _RGB32(this.r, this.g, this.b)

            leftSide = .4
            PAINT (x - (voxelSize / 4), y + (voxelSize * 0.7)), _RGB32(this.r * leftSide, this.g * leftSide, this.b * leftSide), _RGB32(this.r, this.g, this.b)

            PAINT (x + (voxelSize / 4), y + (voxelSize * 0.7)), _RGB32(this.r, this.g, this.b), _RGB32(this.r, this.g, this.b)
        END IF

        this.image = tempImage&

        _DEST previousDest&
    END IF
    _PUTIMAGE (this.x, this.y), this.image
END SUB
