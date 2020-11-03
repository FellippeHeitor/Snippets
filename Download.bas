OPTION _EXPLICIT
DIM remoteFile$, result AS INTEGER, file$, size&

remoteFile$ = "www.qb64.org/amongst/amongst_version.txt"
PRINT "Downloading "; remoteFile$; "[";
DO
    result = Download(remoteFile$, 30, size&, file$)
    IF size& THEN
        COLOR 8
        DIM r%, c%
        r% = CSRLIN
        c% = POS(1)
        LOCATE 2, 1
        PRINT "Size:"; size&; "bytes"
        COLOR 7
        LOCATE r%, c%
    END IF
    SELECT CASE result
        CASE 0 'success
            PRINT "]"
            PRINT
            COLOR 14
            PRINT file$
            COLOR 7
            EXIT DO
        CASE 1 'still working
            PRINT ".";
        CASE 2 'can't connect
            PRINT "X] - failed to connect."
        CASE 3 'timed out
            PRINT "X] - connection timed out."
    END SELECT
    _LIMIT 10
LOOP

FUNCTION Download% (url$, timelimit, contentSize AS LONG, contents$)
    'adapted from http://www.qb64.org/wiki/Downloading_Files
    '
    'Usage:
    '    Call Download%() in a loop until one of the return codes
    '    bellow is returned. Contents downloaded are returned in
    '    the contents$ variable.
    '
    'Return codes:
    '    0 = success
    '    1 = still working
    '    2 = can't connect
    '    3 = timed out

    STATIC client AS LONG, l AS LONG
    STATIC prevUrl$, prevUrl2$, a$, a2$, url2$, url3$
    STATIC x AS LONG, i AS LONG, i2 AS LONG, i3 AS LONG
    STATIC e$, x$, t!, d$, fh AS INTEGER

    IF url$ = "" THEN
        IF client THEN CLOSE client: client = 0
        prevUrl$ = ""
        EXIT SUB
    END IF

    IF url$ <> prevUrl$ THEN
        prevUrl$ = url$
        a$ = ""
        url2$ = url$
        x = INSTR(url2$, "/")
        IF x THEN url2$ = LEFT$(url$, x - 1)
        IF url2$ <> prevUrl2$ THEN
            prevUrl2$ = url2$
            IF client THEN CLOSE client: client = 0
            client = _OPENCLIENT("TCP/IP:80:" + url2$)
            IF client = 0 THEN Download = 2: prevUrl$ = "": EXIT FUNCTION
        END IF
        e$ = CHR$(13) + CHR$(10) ' end of line characters
        url3$ = RIGHT$(url$, LEN(url$) - x + 1)
        x$ = "GET " + url3$ + " HTTP/1.1" + e$
        x$ = x$ + "Host: " + url2$ + e$ + e$
        PUT #client, , x$
        t! = TIMER ' start time
    END IF

    GET #client, , a2$
    a$ = a$ + a2$
    i = INSTR(a$, "Content-Length:")
    IF i THEN
        i2 = INSTR(i, a$, e$)
        IF i2 THEN
            l = VAL(MID$(a$, i + 15, i2 - i - 14))
            contentSize = l
            i3 = INSTR(i2, a$, e$ + e$)
            IF i3 THEN
                i3 = i3 + 4 'move i3 to start of data
                IF (LEN(a$) - i3 + 1) = l THEN
                    d$ = MID$(a$, i3, l)
                    fh = FREEFILE
                    Download = 0
                    contents$ = d$
                    prevUrl$ = ""
                    prevUrl2$ = ""
                    a$ = ""
                    CLOSE client
                    client = 0
                    EXIT FUNCTION
                END IF ' availabledata = l
            END IF ' i3
        END IF ' i2
    END IF ' i
    IF TIMER > t! + timelimit THEN CLOSE client: client = 0: Download = 3: prevUrl$ = "": EXIT FUNCTION
    Download = 1 'still working
END FUNCTION
