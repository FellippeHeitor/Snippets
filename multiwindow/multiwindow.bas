': This program uses
': InForm - GUI library for QB64 - v1.3
': Fellippe Heitor, 2016-2020 - fellippe@qb64.org - @fellippeheitor
': https://github.com/FellippeHeitor/InForm
'-----------------------------------------------------------

': Controls' IDs: ------------------------------------------------------------------
'Form1
DIM SHARED Form1 AS LONG
DIM SHARED ClickMeIDareYouBT AS LONG

'Form2
DIM SHARED ILikeYou AS LONG
DIM SHARED ArentYouBoldLB AS LONG

DIM SHARED Host AS LONG, __UI_MainApp AS LONG

CONST endSignal = "<END>"

DECLARE DYNAMIC LIBRARY "user32"
    FUNCTION SetForegroundWindow& (BYVAL hWnd AS LONG)
END DECLARE

': External modules: ---------------------------------------------------------------
'$INCLUDE:'InForm\InForm.ui'
'$INCLUDE:'InForm\xp.uitheme'
'$INCLUDE:'multiwindow.frm'

': Event procedures: ---------------------------------------------------------------
SUB __UI_BeforeInit

END SUB

SUB __UI_OnLoad
    IF INSTR(COMMAND$, "--InForm:") = 0 THEN
        DIM HostAttemps AS INTEGER
        DIM HostPort AS STRING
        HostAttempts = 0
        DO
            HostAttempts = HostAttempts + 1
            HostPort = LTRIM$(STR$(INT(RND * 5000 + 60000)))
            Host = _OPENHOST("TCP/IP:" + HostPort)
        LOOP UNTIL Host <> 0 OR HostAttempts > 1000

        IF Host THEN
            SHELL _DONTWAIT CHR$(34) + COMMAND$(0) + CHR$(34) + " --InForm:2 --InFormPort:" + HostPort
        END IF
    ELSE
        _SCREENHIDE
    END IF
END SUB

SUB __UI_BeforeUpdateDisplay
    'This event occurs at approximately 30 frames per second.
    'You can change the update frequency by calling SetFrameRate DesiredRate%
    SHARED SubWindow AS LONG, SubWindowStream AS STRING
    SHARED MainAppStream AS STRING
    IF INSTR(COMMAND$, "--InForm:") = 0 THEN
        DIM id AS LONG, value$
        IF SubWindow = 0 AND Host < 0 THEN
            SubWindow = _OPENCONNECTION(Host)
        ELSEIF SubWindow THEN
            getData SubWindow, SubWindowStream
            WHILE parse(SubWindowStream, id, value$)
                SELECT CASE value$
                    CASE "__UI_Click"
                        __UI_Click id
                END SELECT
            WEND
        END IF
    ELSE
        getData __UI_MainApp, MainAppStream
        WHILE parse(MainAppStream, id, value$)
            IF id THEN
                SELECT CASE value$
                    CASE "__UI_Click"
                        __UI_Click id
                END SELECT
            ELSE
                SELECT CASE value$
                    CASE "SHOW"
                        _SCREENSHOW
                        i = SetForegroundWindow&(_WINDOWHANDLE)
                    CASE "UNLOAD"
                        SYSTEM
                END SELECT
            END IF
        WEND
    END IF
END SUB

SUB __UI_BeforeUnload
    'If you set __UI_UnloadSignal = False here you can
    'cancel the user's request to close.
    SHARED SubWindow AS LONG, SubWindowStream AS STRING
    IF INSTR(COMMAND$, "--InForm:") THEN
        _SCREENHIDE
        __UI_UnloadSignal = False
    ELSE
        sendData SubWindow, 0, "UNLOAD"
    END IF
END SUB

SUB __UI_Click (id AS LONG)
    SHARED SubWindow AS LONG, SubWindowStream AS STRING
    SELECT CASE id
        CASE Form1

        CASE ClickMeIDareYouBT
            sendData SubWindow, 0, "SHOW"
        CASE ILikeYou

        CASE ArentYouBoldLB

    END SELECT
END SUB

SUB __UI_MouseEnter (id AS LONG)
    SELECT CASE id
        CASE Form1

        CASE ClickMeIDareYouBT

        CASE ILikeYou

        CASE ArentYouBoldLB

    END SELECT
END SUB

SUB __UI_MouseLeave (id AS LONG)
    SELECT CASE id
        CASE Form1

        CASE ClickMeIDareYouBT

        CASE ILikeYou

        CASE ArentYouBoldLB

    END SELECT
END SUB

SUB __UI_FocusIn (id AS LONG)
    SELECT CASE id
        CASE ClickMeIDareYouBT

    END SELECT
END SUB

SUB __UI_FocusOut (id AS LONG)
    'This event occurs right before a control loses focus.
    'To prevent a control from losing focus, set __UI_KeepFocus = True below.
    SELECT CASE id
        CASE ClickMeIDareYouBT

    END SELECT
END SUB

SUB __UI_MouseDown (id AS LONG)
    SELECT CASE id
        CASE Form1

        CASE ClickMeIDareYouBT

        CASE ILikeYou

        CASE ArentYouBoldLB

    END SELECT
END SUB

SUB __UI_MouseUp (id AS LONG)
    SELECT CASE id
        CASE Form1

        CASE ClickMeIDareYouBT

        CASE ILikeYou

        CASE ArentYouBoldLB

    END SELECT
END SUB

SUB __UI_KeyPress (id AS LONG)
    'When this event is fired, __UI_KeyHit will contain the code of the key hit.
    'You can change it and even cancel it by making it = 0
    SELECT CASE id
        CASE ClickMeIDareYouBT

    END SELECT
END SUB

SUB __UI_TextChanged (id AS LONG)
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_ValueChanged (id AS LONG)
    SELECT CASE id
    END SELECT
END SUB

SUB __UI_FormResized

END SUB

SUB sendData (client AS LONG, id AS LONG, value$)
    DIM packet$
    packet$ = MKL$(id) + value$ + endSignal
    IF client THEN
        PUT #client, , packet$
    END IF
END SUB

SUB getData (client AS LONG, buffer AS STRING)
    DIM incoming$
    STATIC lastTime$
    IF lastTime$ <> TIME$ THEN
        lastTime$ = TIME$
    END IF
    IF client THEN
        GET #client, , incoming$
        buffer = buffer + incoming$
    END IF
END SUB

FUNCTION parse%% (buffer AS STRING, id AS LONG, value$)
    DIM endMarker AS LONG
    endMarker = INSTR(buffer, endSignal)
    IF endMarker THEN
        id = CVL(LEFT$(buffer, 4))
        value$ = MID$(buffer, 5, endMarker - 5)
        buffer = MID$(buffer, endMarker + LEN(endSignal))
        parse%% = True
    END IF
END FUNCTION

FUNCTION getCVS! (buffer$)
    getCVS! = CVS(LEFT$(buffer$, 4))
    buffer$ = MID$(buffer$, 5)
END FUNCTION

FUNCTION getCVI% (buffer$)
    getCVI% = CVI(LEFT$(buffer$, 2))
    buffer$ = MID$(buffer$, 3)
END FUNCTION

FUNCTION getCVL& (buffer$)
    getCVL& = CVL(LEFT$(buffer$, 4))
    buffer$ = MID$(buffer$, 5)
END FUNCTION

