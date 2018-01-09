SCREEN _NEWIMAGE(400, 400, 32)
_PUTIMAGE , IconPreview("source/qb64.ico")
SLEEP

FUNCTION IconPreview& (IconFile$)
    DIM IconFileNum AS INTEGER
    DIM Preferred AS INTEGER, Largest AS INTEGER
    DIM i AS LONG, a$

    TYPE ICONTYPE
        Reserved AS INTEGER: ID AS INTEGER: Count AS INTEGER
    END TYPE

    TYPE ICONENTRY
        PWidth AS _UNSIGNED _BYTE: PDepth AS _UNSIGNED _BYTE
        NumColors AS _BYTE: RES2 AS _BYTE
        NumberPlanes AS INTEGER: BitsPerPixel AS INTEGER
        DataSize AS LONG: DataOffset AS LONG
    END TYPE

    TYPE BMPENTRY
        ID AS STRING * 2: Size AS LONG: Res1 AS INTEGER: Res2 AS INTEGER: Offset AS LONG
    END TYPE

    TYPE BMPHeader
        Hsize AS LONG: PWidth AS LONG: PDepth AS LONG
        Planes AS INTEGER: BPP AS INTEGER
        Compression AS LONG: ImageBytes AS LONG
        Xres AS LONG: Yres AS LONG: NumColors AS LONG: SigColors AS LONG
    END TYPE

    DIM ICO AS ICONTYPE
    DIM BMP AS BMPENTRY
    DIM BMPHeader AS BMPHeader

    IF _FILEEXISTS(IconFile$) = 0 THEN EXIT FUNCTION

    IconFileNum = FREEFILE
    OPEN IconFile$ FOR BINARY AS #IconFileNum
    GET #IconFileNum, 1, ICO
    IF ICO.ID <> 1 THEN CLOSE #IconFileNum: EXIT FUNCTION

    DIM Entry(ICO.Count) AS ICONENTRY
    Preferred = 0
    Largest = 0

    FOR i = 1 TO ICO.Count
        GET #IconFileNum, , Entry(i)
        IF Entry(i).BitsPerPixel = 32 THEN
            IF Entry(i).PWidth = 0 THEN Entry(i).PWidth = 256
            IF Entry(i).PWidth > Largest THEN Largest = Entry(i).PWidth: Preferred = i
        END IF
    NEXT

    IF Preferred = 0 THEN EXIT FUNCTION

    a$ = SPACE$(Entry(Preferred).DataSize)
    GET #IconFileNum, Entry(Preferred).DataOffset + 1, a$
    CLOSE #IconFileNum

    IF LEFT$(a$, 4) = CHR$(137) + "PNG" THEN
        'PNG data can be dumped to the disk directly
        OPEN IconFile$ + ".preview.png" FOR BINARY AS #IconFileNum
        PUT #IconFileNum, 1, a$
        CLOSE #IconFileNum
        i = _LOADIMAGE(IconFile$ + ".preview.png", 32)
        IF i = -1 THEN i = 0
        IconPreview& = i
        KILL IconFile$ + ".preview.png"
        EXIT FUNCTION
    ELSE
        'BMP data requires a header to be added
        BMP.ID = "BM"
        BMP.Size = LEN(BMP) + LEN(BMPHeader) + LEN(a$)
        BMP.Offset = LEN(BMP) + LEN(BMPHeader)
        BMPHeader.Hsize = 40
        BMPHeader.PWidth = Entry(Preferred).PWidth
        BMPHeader.PDepth = Entry(Preferred).PDepth: IF BMPHeader.PDepth = 0 THEN BMPHeader.PDepth = 256
        BMPHeader.Planes = 1
        BMPHeader.BPP = 32
        OPEN IconFile$ + ".preview.bmp" FOR BINARY AS #IconFileNum
        PUT #IconFileNum, 1, BMP
        PUT #IconFileNum, , BMPHeader
        a$ = MID$(a$, 41)
        PUT #IconFileNum, , a$
        CLOSE #IconFileNum
        i = _LOADIMAGE(IconFile$ + ".preview.bmp", 32)
        IF i < -1 THEN 'Loaded properly
            _SOURCE i
            IF POINT(0, 0) = _RGB32(0, 0, 0) THEN _CLEARCOLOR _RGB32(0, 0, 0), i
            _SOURCE 0
        ELSE
            i = 0
        END IF
        IconPreview& = i
        KILL IconFile$ + ".preview.bmp"
        EXIT FUNCTION
    END IF
END FUNCTION

