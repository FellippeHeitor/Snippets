CONST true = -1, false = NOT true

DIM SHARED mouseX AS SINGLE, mouseY AS SINGLE
DIM SHARED mB1 AS _BYTE, mB2 AS _BYTE
DIM SHARED mouseWheel AS INTEGER

SCREEN _NEWIMAGE(800, 450, 32)
boxY = _HEIGHT / 2
DO
    getInput 0
    CLS
    PRINT mouseX, mouseY
    PRINT mB1, mB2
    PRINT mouseWheel

    IF mousedown THEN
        boxY = mouseY
    ELSE
        boxY = boxY - mouseWheel
    END IF
    IF boxY < 20 THEN boxY = 20
    IF boxY > _HEIGHT - 20 THEN boxY = _HEIGHT - 20

    'line
    LINE (_WIDTH / 2, 20)-(_WIDTH / 2, _HEIGHT - 20)

    'box
    inBox = false
    LINE (_WIDTH / 2 - 10, boxY - 10)-STEP(20, 20), , B
    IF mousedown OR (mouseX >= _WIDTH / 2 - 10 AND mouseX <= _WIDTH / 2 + 10 AND mouseY >= boxY - 10 AND mouseY <= boxY + 10) THEN
        LINE (_WIDTH / 2 - 10, boxY - 10)-STEP(20, 20), _RGBA32(255, 255, 255, 100), BF
        inBox = true
    END IF

    IF mB1 AND NOT mousedown THEN
        IF inBox THEN mousedown = true
    ELSEIF NOT mB1 THEN
        mousedown = false
    END IF

    _DISPLAY
    _LIMIT 30
LOOP

SUB getInput (ForceSwap%%)
    'Mouse input (optimization kindly provided by Luke Ceddia):
    mouseWheel = 0
    IF _MOUSEINPUT THEN
        mouseWheel = mouseWheel + _MOUSEWHEEL
        IF GetProperMouseButton%%(1, ForceSwap%%) = mB1 AND GetProperMouseButton%%(2, ForceSwap%%) = mB2 THEN
            DO WHILE _MOUSEINPUT
                mouseWheel = mouseWheel + _MOUSEWHEEL
                IF NOT (GetProperMouseButton%%(1, ForceSwap%%) = mB1 AND GetProperMouseButton%%(2, ForceSwap%%) = mB2) THEN EXIT DO
            LOOP
        END IF
        mB1 = GetProperMouseButton%%(1, ForceSwap%%)
        mB2 = GetProperMouseButton%%(2, ForceSwap%%)
        mouseX = _MOUSEX
        mouseY = _MOUSEY
    END IF
END SUB

FUNCTION GetProperMouseButton%% (Which%%, ForceSwap%%)
    $IF WIN THEN
        DECLARE LIBRARY
            FUNCTION GetSystemMetrics& (BYVAL WhichMetric&)
        END DECLARE

        CONST SM_SWAPBUTTON = 23

        IF GetSystemMetrics(SM_SWAPBUTTON) = 0 THEN
            GetProperMouseButton%% = _MOUSEBUTTON(Which%%)
        ELSE
            IF Which%% = 1 THEN
                GetProperMouseButton%% = _MOUSEBUTTON(2)
            ELSEIF Which%% = 2 THEN
                GetProperMouseButton%% = _MOUSEBUTTON(1)
            END IF
        END IF
    $ELSE
        IF ForceSwap%% THEN
        IF Which%% = 1 THEN
        GetProperMouseButton%% = _MOUSEBUTTON(2)
        ELSEIF Which%% = 2 THEN
        GetProperMouseButton%% = _MOUSEBUTTON(1)
        END IF
        ELSE
        GetProperMouseButton%% = _MOUSEBUTTON(Which%%)
        END IF
    $END IF
END FUNCTION


