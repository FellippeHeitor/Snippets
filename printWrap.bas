$DEBUG
a$ = "Hello, it's me. I was wondering if after all these" + _
     " years you'd like to meet to go over everything. They" + _
     " say that time's supposed to heal you, but I ain't done much healing."

DO
    WHILE _MOUSEINPUT: WEND
    IF _MOUSEBUTTON(1) THEN
        CLS
        IF _MOUSEX > 0 AND _MOUSEX < _WIDTH AND _MOUSEY > 0 AND _MOUSEY < _HEIGHT THEN
            printWrap _MOUSEX, _MOUSEY, a$
        ELSE
            PRINT "error"
        END IF
        WHILE _MOUSEBUTTON(1): i = _MOUSEINPUT: WEND
    END IF
    _DISPLAY
    _LIMIT 30
LOOP

SUB printWrap (x AS INTEGER, y AS INTEGER, __text$)
    DIM text$, nextWord$
    DIM AS LONG findSep, initialX
    text$ = __text$

    initialX = x
    LOCATE y, x
    DO WHILE LEN(_TRIM$(text$))
        findSep = INSTR(text$, " ")
        IF findSep THEN
            nextWord$ = LEFT$(text$, findSep)
        ELSE
            findSep = LEN(text$)
            nextWord$ = text$
        END IF
        text$ = MID$(text$, findSep + 1)
        IF POS(0) + LEN(nextWord$) > _WIDTH THEN
            LOCATE CSRLIN + 1, initialX
        END IF
        PRINT nextWord$;
    LOOP
END SUB
