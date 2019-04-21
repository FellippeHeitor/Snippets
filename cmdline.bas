$CONSOLE:ONLY
_DEST _CONSOLE

bar$ = strParameter("bar")
quuz% = intParameter("quux")

PRINT "You passed:"
PRINT "    1- "; bar$
PRINT "    2- "; quuz%

SYSTEM

FUNCTION strParameter$ (which$)
    FOR i = 1 TO _COMMANDCOUNT - 1
        IF UCASE$("-" + which$) = UCASE$(COMMAND$(i)) THEN
            strParameter$ = COMMAND$(i + 1)
            EXIT FUNCTION
        END IF
    NEXT
END FUNCTION

FUNCTION intParameter% (which$)
    intParameter% = VAL(strParameter$(which$))
END FUNCTION

