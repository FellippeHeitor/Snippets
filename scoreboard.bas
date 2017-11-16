'Here are the contents of the php files
'you must upload to your server (you must
'also upload an empty "theboard.txt" file):
'
'getboard.php:
'<?php
'    if ($_GET['auth'] == '1234') {
'        $theboard = @file_get_contents('theboard.txt');
'        echo '<p>';
'        echo $theboard;
'        echo '</p>';
'    }
'?>
'
'updateboard.php:
'<?php
'    if ($_GET['auth'] == '1234') {
'        $newboard = $_GET['newboard'];
'        @file_put_contents('theboard.txt', $newboard);
'        echo '<p>success</p>';
'    } else {
'        echo '<p>authfail</p>';
'    }
'?>



CONST auth = "1234"
CONST host = "www.sxript.com"
CONST getboardpath = "/sxript/getboard.php"
CONST updateboardpath = "/sxript/updateboard.php"
CONST timelimit = 10

DO
    CLS
    COLOR 7
    PRINT "Let's play a game."
    PRINT "Hit ENTER to win"
    PRINT "Hit ESC to lose"
    COLOR 2: PRINT "GO!": COLOR 15

    k& = _KEYHIT
    IF k& = 13 THEN win = -1: PRINT "You win!"
    IF k& = 27 THEN lose = -1: PRINT "You lose..."

    _DISPLAY
    _LIMIT 30
LOOP UNTIL win OR lose

_AUTODISPLAY

_KEYCLEAR

IF win THEN
    INPUT "Your name:", name$
    name$ = LTRIM$(RTRIM$(UCASE$(name$)))
    PRINT "Connecting to server..."
    board$ = downloadBoard
    board$ = Replace(board$, "-", CHR$(10), 0, 0)
    IF INSTR(board$, "/" + name$ + "/") THEN
        PRINT "Your name is already in the Winner's Board:"
        PRINT board$
    ELSE
        IF LEN(board$) > 0 AND RIGHT$(board$, 1) <> CHR$(10) THEN board$ = board$ + CHR$(10)
        board$ = board$ + "/" + name$ + "/" + CHR$(10)
        PRINT "Updating board..."
        uploadBoard board$
        PRINT "Congrats, "; name$; "!"
        PRINT board$
    END IF
END IF

FUNCTION downloadBoard$
    randomvalue$ = LTRIM$(STR$(INT(RND * 1000000)))
    client = _OPENCLIENT("TCP/IP:80:" + host)
    IF client = 0 THEN PRINT "Can't connect to server.": END
    crlf$ = CHR$(13) + CHR$(10)
    request$ = "GET " + getboardpath + "?rand=" + randomvalue$ + "&auth=" + auth + " HTTP/1.1" + crlf$
    request$ = request$ + "Host: " + host + crlf$ + crlf$
    PUT #client, , request$
    t! = TIMER
    DO
        _DELAY .05
        GET #client, , a2$
        a$ = a$ + a2$
        IF INSTR(a$, crlf$) THEN EXIT DO
    LOOP UNTIL TIMER > t! + timelimit
    CLOSE client

    p1 = INSTR(a$, "<p>")
    IF p1 > 0 THEN
        p2 = INSTR(p + 1, a$, "</p>")
        IF p2 = 0 THEN PRINT "Can't connect to server.": END
    END IF

    board$ = MID$(a$, p1 + 3, p2 - p1 - 3)
    downloadBoard$ = board$
END SUB

SUB uploadBoard (__newboard$)
    randomvalue$ = LTRIM$(STR$(INT(RND * 1000000)))
    newboard$ = Replace(__newboard$, CHR$(10), "-", 0, 0)

    client = _OPENCLIENT("TCP/IP:80:" + host)
    IF client = 0 THEN PRINT "Can't connect to server.": END
    crlf$ = CHR$(13) + CHR$(10)
    request$ = "GET " + updateboardpath + "?rand=" + randomvalue$ + "&auth=" + auth + "&newboard=" + newboard$ + " HTTP/1.1" + crlf$
    request$ = request$ + "Host: " + host + crlf$ + crlf$
    PUT #client, , request$
    t! = TIMER
    DO
        _DELAY .05
        GET #client, , a2$
        a$ = a$ + a2$
        IF INSTR(a$, crlf$) THEN EXIT DO
    LOOP UNTIL TIMER > t! + timelimit
    CLOSE client

    p1 = INSTR(a$, "<p>")
    IF p1 > 0 THEN
        p2 = INSTR(p + 1, a$, "</p>")
        IF p2 = 0 THEN PRINT "Error updating Winner's Board.": END
    END IF

    result$ = MID$(a$, p1 + 3, p2 - p1 - 3)
    IF result$ = "success" THEN PRINT "Winner's Board updated with your name.": EXIT SUB

    PRINT "Error updating Winner's Board."
END SUB

FUNCTION Replace$ (TempText$, SubString$, NewString$, CaseSensitive AS _BYTE, TotalReplacements AS LONG)
    DIM FindSubString AS LONG, Text$

    IF LEN(TempText$) = 0 THEN EXIT SUB

    Text$ = TempText$
    TotalReplacements = 0
    DO
        IF CaseSensitive THEN
            FindSubString = INSTR(FindSubString + 1, Text$, SubString$)
        ELSE
            FindSubString = INSTR(FindSubString + 1, UCASE$(Text$), UCASE$(SubString$))
        END IF
        IF FindSubString = 0 THEN EXIT DO
        IF LEFT$(SubString$, 1) = "\" THEN 'Escape sequence
            'Replace the Substring if it's not preceeded by another backslash
            IF MID$(Text$, FindSubString - 1, 1) <> "\" THEN
                Text$ = LEFT$(Text$, FindSubString - 1) + NewString$ + MID$(Text$, FindSubString + LEN(SubString$))
                TotalReplacements = TotalReplacements + 1
            END IF
        ELSE
            Text$ = LEFT$(Text$, FindSubString - 1) + NewString$ + MID$(Text$, FindSubString + LEN(SubString$))
            TotalReplacements = TotalReplacements + 1
        END IF
    LOOP

    Replace$ = Text$
END FUNCTION

