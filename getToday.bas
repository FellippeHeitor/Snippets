PRINT getToday$

FUNCTION getToday$
    host$ = "www.qb64.org"
    getpath$ = "/today.php"
    timelimit = 10

    randomvalue$ = LTRIM$(STR$(INT(RND * 1000000)))
    client = _OPENCLIENT("TCP/IP:80:" + host$)
    IF client = 0 THEN EXIT FUNCTION
    crlf$ = CHR$(13) + CHR$(10)
    request$ = "GET " + getpath$ + "?rand=" + randomvalue$ + " HTTP/1.1" + crlf$
    request$ = request$ + "Host: " + host$ + crlf$ + crlf$
    PUT #client, , request$
    t! = TIMER
    DO
        _DELAY .05
        GET #client, , a2$
        a$ = a$ + a2$
        IF INSTR(a$, crlf$) THEN EXIT DO
    LOOP UNTIL TIMER > t! + timelimit
    CLOSE client

    p1 = INSTR(a$, "<body>")
    IF p1 > 0 THEN
        p2 = INSTR(p + 1, a$, "</body>")
        IF p2 = 0 THEN EXIT FUNCTION
    ELSE
        EXIT FUNCTION
    END IF

    getToday$ = MID$(a$, p1 + 6, p2 - p1 - 6)
END SUB

