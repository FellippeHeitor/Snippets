CONST true = -1, false = NOT true

host$ = "127.0.0.1" 'localhost
port$ = "4774"
timeout = 10

PRINT "Starting server..."
DO
    s = _OPENHOST("TCP/IP:" + port$)
    IF s = 0 THEN
        PRINT "Can't start server. Retry (y/n)?"
        a$ = INPUT$(1)
        IF LCASE$(a$) <> "y" THEN END
    ELSE
        EXIT DO
    END IF
LOOP

PRINT "Waiting for a client...";
DO
    c = _OPENCONNECTION(s)
    IF c THEN EXIT DO
LOOP

PRINT "Connected."
PRINT "Waiting for requests...";

DO
    GET #c, , a$
    result$ = result$ + a$

    IF LEN(result$) > 0 AND requestStarted = false THEN
        requestStarted = true
        PRINT
        thisLine = CSRLIN
    ELSEIF LEN(result$) > 0 THEN
        LOCATE thisLine, 1
        PRINT LEN(result$); " bytes received"
    END IF

    IF INSTR(result$, CHR$(13)) THEN 'end of message received
        requestStarted = false
        PRINT "Received: "; result$
        result$ = UCASE$(result$)
        PUT #c, , result$
        PRINT "Returned: "; result$
        result$ = ""
        PRINT "Waiting for requests...";
    END IF

    k = _KEYHIT
LOOP UNTIL k = 27

CLOSE s
