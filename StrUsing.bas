OPTION _EXPLICIT

DIM money AS _FLOAT, tmp$

money = 12345.45
tmp$ = "$$#######,.##"

PRINT "I have this much money!"; USING tmp$; money
PRINT "I have this much money!"; StrUsing(tmp$, money)

FUNCTION StrUsing$ (format$, value##)
    DIM prevDest AS LONG, prevSource AS LONG
    DIM tempScreen AS LONG
    DIM i AS LONG, temp$
    DIM length AS LONG

    prevDest = _DEST
    prevSource = _SOURCE

    tempScreen = _NEWIMAGE(LEN(format$) * 2, 2, 0)
    _DEST tempScreen
    _SOURCE tempScreen

    PRINT USING format$; value##;

    length = POS(0) - 1
    temp$ = SPACE$(length)
    FOR i = 1 TO length
        ASC(temp$, i) = SCREEN(1, i)
    NEXT

    _DEST prevDest
    _SOURCE prevSource
    _FREEIMAGE tempScreen

    StrUsing$ = temp$
END FUNCTION
