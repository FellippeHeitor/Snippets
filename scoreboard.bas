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
'        $newboard = stripslashes($_GET['newboard']);
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
CONST filename$ = "highscores.dat"
CONST maxHighScores = 8

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
RANDOMIZE TIMER
score& = RND * 10000

IF win THEN
    PRINT "Connecting to server..."
    board$ = downloadBoard
    PRINT board$

    IF LEN(board$) > 0 THEN 'WRITES THAT TO THE FILE
        OPEN filename$ FOR OUTPUT AS #1
        PRINT #1, board$
        CLOSE #1
    END IF

    TYPE newHighScore
        player AS STRING * 8
        score AS LONG
    END TYPE

    DIM highScore(1 TO maxHighScores) AS newHighScore
    DIM totalHS AS INTEGER

    IF _FILEEXISTS(filename$) THEN
        OPEN filename$ FOR INPUT AS #1
        FOR i = 1 TO maxHighScores
            IF EOF(1) THEN EXIT FOR
            INPUT #1, highScore(i).player
            INPUT #1, highScore(i).score
            totalHS = i
        NEXT
        CLOSE #1
    END IF

    IF totalHS < 8 THEN
        GOTO ENTER_HIGH_SCORE
    ELSEIF totalHS > 0 THEN
        IF score& > highScore(totalHS).score THEN GOTO ENTER_HIGH_SCORE
    END IF
    GOTO HIGH_SCORE_LIST

    ENTER_HIGH_SCORE:
    PRINT "Your score:"; score&
    INPUT "Your name:", playerName$
    playerName$ = LTRIM$(RTRIM$(UCASE$(playerName$)))
    'insert new score into table
    IF totalHS = 0 THEN
        totalHS = 1
        highScore(1).player = playerName$
        highScore(1).score = score&
    ELSE
        IF totalHS < 8 THEN
            FOR i = totalHS TO 1 STEP -1
                IF score& > highScore(i).score THEN
                    insertAt = i
                END IF
            NEXT

            totalHS = totalHS + 1
            IF insertAt = 0 THEN
                highScore(totalHS).player = playerName$
                highScore(totalHS).score = score&
            ELSE
                FOR i = totalHS - 1 TO insertAt STEP -1
                    highScore(i + 1) = highScore(i)
                NEXT
                highScore(insertAt).player = playerName$
                highScore(insertAt).score = score&
            END IF
        ELSEIF totalHS = 8 THEN
            FOR i = totalHS TO 1 STEP -1
                IF score& > highScore(i).score THEN
                    insertAt = i
                END IF
            NEXT

            FOR i = totalHS - 1 TO insertAt STEP -1
                highScore(i + 1) = highScore(i)
            NEXT
            highScore(insertAt).player = playerName$
            highScore(insertAt).score = score&
        END IF
    END IF

    OPEN filename$ FOR OUTPUT AS #1
    board$ = ""
    FOR i = 1 TO totalHS
        WRITE #1, highScore(i).player, highScore(i).score,
        'build the new score line for upload
        board$ = board$ + CHR$(34) + RTRIM$(highScore(i).player) + CHR$(34) + "," + LTRIM$(STR$(highScore(i).score))
        IF i < totalHS THEN board$ = board$ + ","
    NEXT
    CLOSE #1

    PRINT "Updating board..."
    uploadBoard board$

    PRINT "Congrats, "; playerName$; "!"
END IF

HIGH_SCORE_LIST:
PRINT
PRINT "The list:"
FOR i = 1 TO totalHS
    PRINT highScore(i).player, highScore(i).score
NEXT

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

SUB uploadBoard (newboard$)
    randomvalue$ = LTRIM$(STR$(INT(RND * 1000000)))
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

