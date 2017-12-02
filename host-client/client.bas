host$ = "127.0.0.1" 'localhost
port$ = "4774"
timeout = 10

DO
    s = _OPENCLIENT("TCP/IP:" + port$ + ":" + host$)
    IF s = 0 THEN
        PRINT "Can't connect to host. Retry (y/n)?"
        a$ = INPUT$(1)
        IF LCASE$(a$) <> "y" THEN END
    ELSE
        EXIT DO
    END IF
LOOP

PRINT "Connected."
DO
    INPUT "-> ", m$
    message$ = message$ + m$
    IF LCASE$(message$) = "q" THEN EXIT DO
    IF RIGHT$(m$, 1) = "#" THEN
        m$ = LEFT$(m$, LEN(m$) - 1) + CHR$(13)
        PUT #s, , m$

        start = TIMER
        result$ = ""
        DO
            GET #s, , a$
            result$ = result$ + a$
            IF INSTR(result$, CHR$(13)) THEN EXIT DO 'use chr$(13) as an "end of message" marker
        LOOP UNTIL TIMER - start > timeout

        PRINT result$
        message$ = ""
    ELSE
        PUT #s, , m$
    END IF
LOOP

CLOSE s
