CONST max = 30

CONST true = -1, false = NOT true

TYPE newCell
    state AS _BYTE
    gen AS LONG
END TYPE

CONST white = _RGB32(255, 255, 255)
CONST red = _RGB32(200, 67, 50)
CONST black = _RGB32(0, 0, 0)
CONST yellow = _RGB32(222, 194, 44)
CONST green = _RGB32(83, 166, 67)

DIM SHARED original(0 TO max + 1, 0 TO max + 1) AS newCell
DIM SHARED cell(0 TO max + 1, 0 TO max + 1) AS newCell
DIM SHARED tempCell(0 TO max + 1, 0 TO max + 1) AS newCell
DIM SHARED canvas AS LONG, grid AS LONG
DIM SHARED gameOn AS _BYTE, squareSize AS INTEGER
DIM SHARED generations AS LONG, changed AS _BYTE

canvas = _NEWIMAGE(max, max, 32)

SCREEN _NEWIMAGE(600, 600, 32)

squareSize = _WIDTH / max

grid = _COPYIMAGE(0)
_DEST grid
CLS , 0
FOR i = 0 TO _WIDTH STEP squareSize
    LINE (i, 0)-(i, _HEIGHT), _RGB32(40, 40, 40)
    FOR j = 0 TO _HEIGHT STEP squareSize
        LINE (0, j)-(_WIDTH, j), _RGB32(40, 40, 40)
    NEXT
NEXT
_DEST 0

DO
    DO
        k& = _KEYHIT
        IF k& = 13 THEN EXIT DO
        IF k& = 27 THEN
            FOR i = 1 TO max
                FOR j = 1 TO max
                    cell(i, j) = original(i, j)
                    tempCell(i, j) = cell(i, j)
                NEXT
            NEXT
        END IF
        IF k& = ASC("r") OR k& = ASC("R") THEN 'random
            RANDOMIZE TIMER
            FOR i = 1 TO max
                FOR j = 1 TO max
                    IF RND > .6 THEN cell(i, j).state = true ELSE cell(i, j).state = false
                    IF cell(i, j).state THEN cell(i, j).gen = 1 ELSE cell(i, j).gen = 0
                    tempCell(i, j) = cell(i, j)
                NEXT
            NEXT
        END IF

        IF k& = ASC("c") OR k& = ASC("C") THEN 'clear
            FOR i = 1 TO max
                FOR j = 1 TO max
                    cell(i, j).state = false
                    cell(i, j).gen = 0
                    tempCell(i, j) = cell(i, j)
                NEXT
            NEXT
        END IF


        WHILE _MOUSEINPUT: WEND
        x = (_MOUSEX - (_MOUSEX MOD squareSize))
        y = (_MOUSEY - (_MOUSEY MOD squareSize))

        IF _MOUSEBUTTON(1) THEN
            IF NOT mouseDown THEN
                cell(x / squareSize + 1, y / squareSize + 1).state = NOT cell(x / squareSize + 1, y / squareSize + 1).state
                cell(x / squareSize + 1, y / squareSize + 1).gen = 1
                tempCell(x / squareSize + 1, y / squareSize + 1) = cell(x / squareSize + 1, y / squareSize + 1)
                mouseDown = true
                turningOn = cell(x / squareSize + 1, y / squareSize + 1).state
            ELSE
                IF prevX <> x OR prevY <> y THEN
                    prevX = x
                    prevY = y
                    cell(x / squareSize + 1, y / squareSize + 1).state = turningOn
                    cell(x / squareSize + 1, y / squareSize + 1).gen = 1
                    tempCell(x / squareSize + 1, y / squareSize + 1) = cell(x / squareSize + 1, y / squareSize + 1)
                END IF
            END IF
        ELSE
            mouseDown = false
        END IF

        ShowCells

        LINE (x, y)-STEP(squareSize - 1, squareSize - 1), red, B
        PrintAt 0, 0, yellow, STR$(x / squareSize + 1) + "," + STR$(y / squareSize + 1)
        PrintAt 0, _HEIGHT - _FONTHEIGHT, green, "<ENTER>=start life; <R>=random cells; <C>=clear; <ESC>=restore original"

        showGen

        _DISPLAY
        _LIMIT 60
    LOOP

    FOR i = 1 TO max
        FOR j = 1 TO max
            original(i, j) = cell(i, j)
            tempCell(i, j) = cell(i, j)
        NEXT
    NEXT

    gameOn = true
    generations = 1

    DO
        ShowCells
        DoTheConwayThing

        k& = _KEYHIT
        IF k& = 13 THEN EXIT DO
        IF k& = 27 THEN
            FOR i = 1 TO max
                FOR j = 1 TO max
                    cell(i, j) = original(i, j)
                    tempCell(i, j) = cell(i, j)
                NEXT
            NEXT
            EXIT DO
        END IF

        WHILE _MOUSEINPUT
            IF _MOUSEBUTTON(1) THEN
                mouseDown = true
                EXIT DO
            END IF
        WEND

        IF _KEYDOWN(32) THEN _LIMIT 60 ELSE _LIMIT 5
    LOOP UNTIL NOT changed OR stuckOscillators

    gameOn = false
LOOP

SUB DoTheConwayThing
    changed = false

    FOR i = 1 TO max
        FOR j = 1 TO max
            neighbors = 0
            IF cell(i - 1, j - 1).state THEN neighbors = neighbors + 1
            IF cell(i, j - 1).state THEN neighbors = neighbors + 1
            IF cell(i + 1, j - 1).state THEN neighbors = neighbors + 1
            IF cell(i - 1, j).state THEN neighbors = neighbors + 1
            IF cell(i + 1, j).state THEN neighbors = neighbors + 1
            IF cell(i - 1, j + 1).state THEN neighbors = neighbors + 1
            IF cell(i, j + 1).state THEN neighbors = neighbors + 1
            IF cell(i + 1, j + 1).state THEN neighbors = neighbors + 1

            IF neighbors = 3 THEN
                tempCell(i, j).state = true
                IF cell(i, j).state THEN tempCell(i, j).gen = cell(i, j).gen + 1
            END IF
            IF neighbors = 2 AND cell(i, j).state THEN
                tempCell(i, j).state = true
                tempCell(i, j).gen = cell(i, j).gen + 1
            END IF
            IF neighbors > 3 OR neighbors < 2 THEN
                tempCell(i, j).state = false
                tempCell(i, j).gen = 0
            END IF

            IF tempCell(i, j).state <> cell(i, j).state THEN changed = true
        NEXT
    NEXT

    IF changed THEN generations = generations + 1
END SUB

SUB ShowCells
    DIM c AS INTEGER

    _DEST canvas
    FOR i = 1 TO max
        FOR j = 1 TO max
            IF gameOn THEN cell(i, j) = tempCell(i, j)
            IF gameOn THEN c = cell(i, j).gen * 10 ELSE c = 255
            IF c < 50 THEN c = 50
            IF cell(i, j).state THEN
                PSET (i - 1, j - 1), _RGB32(c, c, c)
            ELSE
                PSET (i - 1, j - 1), black
            END IF
        NEXT
    NEXT
    _DEST 0
    _PUTIMAGE , canvas
    _PUTIMAGE , grid
    IF gameOn THEN
        showGen
        PrintAt 0, _HEIGHT - _FONTHEIGHT, green, "<SPACE>=speed up; <ENTER>=edit current generation; <ESC>=undo evolution;"
        _DISPLAY
    END IF
END SUB

SUB showGen
    IF gameOn THEN
        m$ = "gen:" + STR$(generations)
    ELSEIF generations THEN
        m$ = "last gen:" + STR$(generations)
    END IF
    l = LEN(m$)
    IF l THEN PrintAt _WIDTH - _FONTWIDTH * l, 0, green, m$
END SUB


SUB PrintAt (x AS INTEGER, y AS INTEGER, c AS _UNSIGNED LONG, t$)
    COLOR black, 0
    _PRINTSTRING (x + 1, y + 1), t$
    COLOR c, 0
    _PRINTSTRING (x, y), t$
END SUB

FUNCTION stuckOscillators%%
    'maybe we're in a final arrangement with oscillators;
    'in such case, we can safely stop life simulation, or else
    'generations will be endless

    STATIC gens$(1 TO 4)
    DIM i AS LONG

    thisGen$ = readGen$(cell())

    FOR i = 3 TO 1 STEP -1
        gens$(i + 1) = gens$(i)
    NEXT
    gens$(1) = thisGen$

    IF gens$(1) = gens$(3) AND gens$(2) = gens$(4) THEN stuckOscillators%% = true
END FUNCTION

FUNCTION readGen$ (this() AS newCell)
    DIM i AS LONG, j AS LONG
    FOR i = 1 TO max
        FOR j = 1 TO max
            IF this(i, j).state THEN t$ = t$ + "1" ELSE t$ = t$ + "0"
        NEXT
    NEXT
    readGen$ = t$
END FUNCTION

SUB restoreGen (gen$, this() AS newCell)
    DIM i AS LONG, j AS LONG
    DIM c AS LONG

    c = 0
    FOR i = 1 TO max
        FOR j = 1 TO max
            c = c + 1
            IF MID$(gen$, c, 1) = "1" THEN
                this(i, j).state = true
                this(i, j).gen = 1
            ELSE
                this(i, j).state = false
                this(i, j).gen = 0
            END IF
        NEXT
    NEXT
END SUB

