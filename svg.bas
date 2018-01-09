'Simple SVG reader for QB64
'Fellippe Heitor, 2017
'A lot of code borrowed as indicated in the comments.
'----------------------------------------------------
IF LEN(COMMAND$) THEN f$ = COMMAND$ ELSE f$ = "wikisample.svg"
IF _FILEEXISTS(f$) = 0 THEN PRINT "File "; f$; " not found.": END

thisScreen& = _NEWIMAGE(800, 600, 32)
SCREEN thisScreen&
_PRINTMODE _KEEPBACKGROUND
CLS , GetColor("white", 1)

OPEN f$ FOR BINARY AS #1
DIM Total AS LONG
DO
    IF EOF(1) THEN EXIT DO
    LINE INPUT #1, l0$
    l$ = RTRIM$(LTRIM$(LCASE$(l0$)))

    DO
        IF RIGHT$(l$, 1) = ">" THEN 'fetch more lines until we close the current tag
            EXIT DO
        ELSE
            IF EOF(1) THEN EXIT DO
            LINE INPUT #1, l2$
            l0$ = l0$ + l2$
            l$ = l$ + RTRIM$(LTRIM$(LCASE$(l2$)))
        END IF
    LOOP

    sp = INSTR(l$, " ")
    IF sp = 0 THEN
        IF l$ = "</svg>" THEN
            EXIT DO
        END IF
    END IF

    Style$ = FindS(l$, "style")
    IF LEN(Style$) THEN
        FillOpacity! = 1
        StrokeOpacity! = 1
        IF INSTR(Style$, "fill-opacity") THEN
            FillOpacity! = Find2(Style$, "fill-opacity")
        ELSEIF INSTR(Style$, "opacity") THEN
            FillOpacity! = Find2(Style$, "opacity")
        END IF
        IF INSTR(Style$, "stroke-opacity") THEN
            StrokeOpacity! = Find2(Style$, "stroke-opacity")
        ELSEIF INSTR(Style$, "opacity") THEN
            StrokeOpacity! = Find2(Style$, "opacity")
        END IF

        Fill$ = FindS2(Style$, "fill")
        FillColor~& = GetColor(Fill$, FillOpacity!)
        Stroke~& = GetColor(FindS2(Style$, "stroke"), StrokeOpacity!)
        StrokeWidth% = Find2(Style$, "stroke-width")
    ELSE
        Fill$ = FindS(l$, "fill")
        FillColor~& = GetColor(Fill$, 1)
        Stroke~& = GetColor(FindS(l$, "stroke"), 1)
        StrokeWidth% = Find(l$, "stroke-width")
    END IF

    SELECT CASE LEFT$(l$, sp - 1)
        CASE "<svg"
            width% = Find(l$, "width")
            height% = Find(l$, "height")
            IF width% > 0 AND height% > 0 THEN
                newScreen& = _NEWIMAGE(width%, height%, 32)
                SCREEN newScreen&
                _PRINTMODE _KEEPBACKGROUND
                CLS , GetColor("white", 1)
                _FREEIMAGE thisScreen&
                thisScreen& = newScreen&
            END IF
        CASE "<rect"
            Total = Total + 1
            x! = Find(l$, "x")
            y! = Find(l$, "y")
            width% = Find(l$, "width")
            height% = Find(l$, "height")

            IF Fill$ <> "none" THEN
                IF INSTR(l$, "rx=") THEN
                    rx! = Find(l$, "rx")
                    RoundRectFill x!, y!, x! + width% - 1, y! + height% - 1, rx!, FillColor~&
                ELSE
                    LINE (x!, y!)-STEP(width% - 1, height% - 1), FillColor~&, BF
                END IF
            END IF

            IF INSTR(l$, "rx=") = 0 THEN
                LINE (x!, y!)-STEP(width% - 1, height% - 1), Stroke~&, B
                FOR i = 1 TO ((StrokeWidth% - 1) / 2)
                    LINE (x! - i, y! - i)-STEP(width% + (i * 2) - 1, height% + (i * 2) - 1), Stroke~&, B
                NEXT
            END IF
        CASE "<circle"
            Total = Total + 1
            cx! = Find(l$, "cx")
            cy! = Find(l$, "cy")
            r! = Find(l$, "r")

            IF Fill$ <> "none" THEN
                CircleFill cx!, cy!, r!, FillColor~&
            END IF

            CIRCLE (cx!, cy!), r!, Stroke~&
        CASE "<ellipse"
            Total = Total + 1
            cx! = Find(l$, "cx")
            cy! = Find(l$, "cy")
            rx! = Find(l$, "rx")
            ry! = Find(l$, "ry")

            IF ry! > rx! THEN SWAP ry!, rx!

            IF Stroke~& = 0 THEN Stroke~& = FillColor~&

            CIRCLE (cx!, cy!), rx!, Stroke~&, , , ry! / rx!

            IF Fill$ <> "none" THEN
                PAINT (cx!, cy!), FillColor~&, Stroke~&
            END IF
        CASE "<polyline"
            Total = Total + 1
            Points$ = FindS(l$, "points")

            sp = INSTR(Points$, " ")
            comma = INSTR(Points$, ",")
            x1! = VAL(LEFT$(Points$, comma - 1))
            IF sp THEN
                y1! = VAL(MID$(Points$, comma + 1, sp - comma))
                Points$ = MID$(Points$, sp + 1)
            ELSE
                y1! = VAL(MID$(Points$, comma + 1))
                Points$ = ""
            END IF

            DO WHILE LEN(Points$)
                sp = INSTR(Points$, " ")
                comma = INSTR(Points$, ",")
                x2! = VAL(LEFT$(Points$, comma - 1))
                IF sp THEN
                    y2! = VAL(MID$(Points$, comma + 1, sp - comma))
                ELSE
                    y2! = VAL(MID$(Points$, comma + 1))
                END IF

                fline x1!, y1!, x2!, y2!, Stroke~&, StrokeWidth%
                x1! = x2!
                y1! = y2!

                IF sp THEN
                    Points$ = MID$(Points$, sp + 1)
                ELSE
                    Points$ = ""
                END IF
            LOOP
        CASE "<polygon"
            Total = Total + 1
            Points$ = FindS(l$, "points")

            sp = INSTR(Points$, " ")
            comma = INSTR(Points$, ",")
            x1! = VAL(LEFT$(Points$, comma - 1))
            IF sp THEN
                y1! = VAL(MID$(Points$, comma + 1, sp - comma))
                Points$ = MID$(Points$, sp + 1)
            ELSE
                y1! = VAL(MID$(Points$, comma + 1))
                Points$ = ""
            END IF

            x! = x1!
            y! = y1!

            DO WHILE LEN(Points$)
                sp = INSTR(Points$, " ")
                comma = INSTR(Points$, ",")
                x2! = VAL(LEFT$(Points$, comma - 1))
                IF sp THEN
                    y2! = VAL(MID$(Points$, comma + 1, sp - comma))
                ELSE
                    y2! = VAL(MID$(Points$, comma + 1))
                END IF

                fline x1!, y1!, x2!, y2!, Stroke~&, StrokeWidth%

                x1! = x2!
                y1! = y2!

                IF sp THEN
                    Points$ = MID$(Points$, sp + 1)
                ELSE
                    Points$ = ""
                END IF
            LOOP

            fline x1!, y1!, x!, y!, Stroke~&, StrokeWidth%

            PAINT (x!, y! + 3), FillColor~&, Stroke~&
        CASE "<line"
            Total = Total + 1
            x1! = Find(l$, "x1")
            y1! = Find(l$, "y1")
            x2! = Find(l$, "x2")
            y2! = Find(l$, "y2")

            fline x1!, y1!, x2!, y2!, Stroke~&, StrokeWidth%
        CASE "<text"
            Total = Total + 1
            '<text x="0" y="15" fill="red">I love SVG!</text>
            x! = Find(l$, "x")
            y! = Find(l$, "y")

            closingTag% = INSTR(l0$, ">")
            endTag% = INSTR(l0$, "</text>")
            text$ = MID$(l0$, closingTag% + 1, endTag% - closingTag% - 1)

            COLOR FillColor~&
            _PRINTSTRING (x!, y!), text$
    END SELECT
LOOP
CLOSE
_TITLE "SVG:" + LTRIM$(STR$(Total)) + " instructions processed"
SLEEP
SYSTEM

FUNCTION FindS$ (theline$, key$)
    line$ = LCASE$(theline$)
    TheKey% = INSTR(LCASE$(line$), LCASE$(key$) + "=" + CHR$(34))
    IF TheKey% THEN
        TheKey% = TheKey% + LEN(key$) + 2
        ClosingQuote% = INSTR(TheKey% + 1, line$, CHR$(34))
        FindS = MID$(line$, TheKey%, ClosingQuote% - TheKey%)
    END IF
END FUNCTION

FUNCTION FindS2$ (theline$, key$)
    line$ = LCASE$(theline$) + ";"
    TheKey% = INSTR(LCASE$(line$), LCASE$(key$) + ":")
    IF TheKey% THEN
        TheKey% = TheKey% + LEN(key$) + 1
        ClosingQuote% = INSTR(TheKey% + 1, line$, ";")
        FindS2 = MID$(line$, TheKey%, ClosingQuote% - TheKey%)
    END IF
END FUNCTION

FUNCTION Find## (theline$, key$)
    line$ = LCASE$(theline$)
    TheKey% = INSTR(LCASE$(line$), LCASE$(key$) + "=" + CHR$(34))
    IF TheKey% THEN
        TheKey% = TheKey% + LEN(key$) + 2
        ClosingQuote% = INSTR(TheKey%, line$, CHR$(34))
        Find = VAL(MID$(line$, TheKey%, ClosingQuote% - TheKey%))
    END IF
END FUNCTION

FUNCTION Find2## (theline$, key$)
    line$ = LCASE$(theline$) + ";"
    TheKey% = INSTR(LCASE$(line$), LCASE$(key$) + ":")
    IF TheKey% THEN
        TheKey% = TheKey% + LEN(key$) + 1
        ClosingQuote% = INSTR(TheKey%, line$, ";")
        Find2 = VAL(MID$(line$, TheKey%, ClosingQuote% - TheKey%))
    END IF
END FUNCTION

SUB RoundRectFill (x AS INTEGER, y AS INTEGER, x1 AS INTEGER, y1 AS INTEGER, r AS INTEGER, c AS _UNSIGNED LONG)
    'This sub from _vincent at the #qb64 chatroom on freenode.net
    LINE (x, y + r)-(x1, y1 - r), c, BF

    a = r
    b = 0
    e = -a

    DO WHILE a >= b
        LINE (x + r - b, y + r - a)-(x1 - r + b, y + r - a), c, BF
        LINE (x + r - a, y + r - b)-(x1 - r + a, y + r - b), c, BF
        LINE (x + r - b, y1 - r + a)-(x1 - r + b, y1 - r + a), c, BF
        LINE (x + r - a, y1 - r + b)-(x1 - r + a, y1 - r + b), c, BF

        b = b + 1
        e = e + b + b
        IF e > 0 THEN
            a = a - 1
            e = e - a - a
        END IF
    LOOP
END SUB

SUB CircleFill (CX AS LONG, CY AS LONG, R AS LONG, C AS LONG)
    'This sub from here: http://www.qb64.net/forum/index.php?topic=1848.msg17254#msg17254
    DIM Radius AS LONG
    DIM RadiusError AS LONG
    DIM X AS LONG
    DIM Y AS LONG

    Radius = ABS(R)
    RadiusError = -Radius
    X = Radius
    Y = 0

    IF Radius = 0 THEN PSET (CX, CY), C: EXIT SUB

    ' Draw the middle span here so we don't draw it twice in the main loop,
    ' which would be a problem with blending turned on.
    LINE (CX - X, CY)-(CX + X, CY), C, BF

    WHILE X > Y

        RadiusError = RadiusError + Y * 2 + 1

        IF RadiusError >= 0 THEN

            IF X <> Y + 1 THEN
                LINE (CX - Y, CY - X)-(CX + Y, CY - X), C, BF
                LINE (CX - Y, CY + X)-(CX + Y, CY + X), C, BF
            END IF

            X = X - 1
            RadiusError = RadiusError - X * 2

        END IF

        Y = Y + 1

        LINE (CX - X, CY - Y)-(CX + X, CY - Y), C, BF
        LINE (CX - X, CY + Y)-(CX + X, CY + Y), C, BF

    WEND

END SUB

SUB fline (x1 AS INTEGER, y1 AS INTEGER, x2 AS INTEGER, y2 AS INTEGER, c AS _UNSIGNED LONG, t AS INTEGER)
    'Adapted from http://www.antonis.de/faq/progs/fatlines.bas
    '***************************************************************************
    ' FATLINES.BAS - Draws a fat line from (x1|y1) to (x2|y2) with color c and
    ' ============   thickness t
    '                Zeichnet eine dicke Linie von (x1|y1) nach (x2|y2) mit der
    '                Farbe c und der Dicke t. Die dicke Linie wird aus mehreren
    '                normalen Linien zusammengesetzt.
    '
    '===========================================================================
    ' Subject: FAT LINES                         Date: 08-06-99 (20:08)
    ' Author:  Marius Andra                      Code: QB, QBasic, PDS
    ' Origin:  marius.andra*mail.ee            Packet: GRAPHICS.ABC
    '***************************************************************************
    LINE (x1, y1)-(x2, y2), c
    IF t = 0 THEN EXIT SUB

    IF x1 = x2 AND y1 <> y2 THEN 'vertical line
        FOR i = 1 TO (t - 1) / 2
            LINE (x1 - i, y1)-(x2 - i, y2), c
            LINE (x1 + i, y1)-(x2 + i, y2), c
        NEXT i
        LINE (x1 - i, y1)-(x2 - i, y2), c
    END IF

    IF y1 = y2 AND x1 <> x2 THEN 'horizontal line
        FOR i = 1 TO (t - 1) / 2
            LINE (x1, y1 - i)-(x2, y2 - i), c
            LINE (x1, y1 + i)-(x2, y2 + i), c
        NEXT i
        LINE (x1, y1 - i)-(x2, y2 - i), c
    END IF

    IF x1 < x2 AND y2 > y1 THEN 'falling line
        FOR i = 1 TO (t - 1) / 2
            LINE (x1 + i, y1)-(x2, y2 - i), c
            LINE (x1, y1 + i)-(x2 - i, y2), c
        NEXT i
        LINE (x1 + i, y1)-(x2, y2 - i), c
    END IF

    IF x2 < x1 AND y2 > y1 THEN 'rising line
        FOR i = 1 TO (t - 1) / 2
            LINE (x1 - i, y1)-(x2, y2 - i), c
            LINE (x1, y1 + i)-(x2 + i, y2), c
        NEXT i
        LINE (x1 - i, y1)-(x2, y2 - i), c
    END IF

    IF x1 < x2 AND y2 < y1 THEN 'rising line
        FOR i = 1 TO (t - 1) / 2
            LINE (x1, y1 - i)-(x2 - i, y2), c
            LINE (x1 + i, y1)-(x2, y2 + i), c
        NEXT i
        LINE (x1, y1 - i)-(x2 - i, y2), c
    END IF

    IF x2 < x1 AND y2 < y1 THEN 'falling line
        FOR i = 1 TO (t - 1) / 2
            LINE (x1, y1 + i)-(x2 - i, y2), c
            LINE (x1 - i, y1)-(x2, y2 + i), c
        NEXT i
        LINE (x1, y1 + i)-(x2 - i, y2), c
    END IF
END SUB

FUNCTION GetColor~& (theColorName$, Alpha!)
    ColorName$ = LCASE$(theColorName$)

    IF LEFT$(ColorName$, 1) = "#" THEN
        c$ = MID$(ColorName$, 2)
        IF LEN(c$) = 6 THEN c$ = HEX$(Alpha! * 255) + c$
        GetColor~& = VAL("&H" + c$)
    ELSEIF LEFT$(ColorName$, 4) = "rgb(" THEN
        cpos% = 5
        comma% = INSTR(cpos%, ColorName$, ",") - 1
        r% = VAL(MID$(ColorName$, cpos%, comma% - cpos% + 1))

        cpos% = comma% + 2
        comma% = INSTR(cpos%, ColorName$, ",") - 1
        g% = VAL(MID$(ColorName$, cpos%, comma% - cpos% + 1))

        cpos% = comma% + 2
        comma% = INSTR(cpos%, ColorName$, ")") - 1
        b% = VAL(MID$(ColorName$, cpos%, comma% - cpos% + 1))

        GetColor~& = _RGBA32(r%, g%, b%, Alpha! * 255)
    ELSE
        RESTORE ColorData
        DO
            READ TheColor$
            IF TheColor$ = "END" THEN EXIT DO
            IF LCASE$(LEFT$(TheColor$, INSTR(TheColor$, "=") - 1)) = ColorName$ THEN
                GetColor~& = VAL("&H" + HEX$(Alpha! * 255) + MID$(TheColor$, INSTR(TheColor$, "=") + 5))
                EXIT DO
            END IF
        LOOP
    END IF

    'Color data from SMcNeill (https://dl.dropboxusercontent.com/u/83161214/Color32.BI):
    ColorData:
    DATA "AliceBlue=&HFFF0F8FF"
    DATA "Almond=&HFFEFDECD"
    DATA "AntiqueBrass=&HFFCD9575"
    DATA "AntiqueWhite=&HFFFAEBD7"
    DATA "Apricot=&HFFFDD9B5"
    DATA "Aqua=&HFF00FFFF"
    DATA "Aquamarine=&HFF7FFFD4"
    DATA "Asparagus=&HFF87A96B"
    DATA "AtomicTangerine=&HFFFFA474"
    DATA "Azure=&HFFF0FFFF"
    DATA "BananaMania=&HFFFAE7B5"
    DATA "Beaver=&HFF9F8170"
    DATA "Beige=&HFFF5F5DC"
    DATA "Bisque=&HFFFFE4C4"
    DATA "Bittersweet=&HFFFD7C6E"
    DATA "Black=&HFF000000"
    DATA "BlanchedAlmond=&HFFFFEBCD"
    DATA "BlizzardBlue=&HFFACE5EE"
    DATA "Blue=&HFF0000FF"
    DATA "BlueBell=&HFFA2A2D0"
    DATA "BlueGray=&HFF6699CC"
    DATA "BlueGreen=&HFF0D98BA"
    DATA "BlueViolet=&HFF8A2BE2"
    DATA "Blush=&HFFDE5D83"
    DATA "BrickRed=&HFFCB4154"
    DATA "Brown=&HFFA52A2A"
    DATA "BurlyWood=&HFFDEB887"
    DATA "BurntOrange=&HFFFF7F49"
    DATA "BurntSienna=&HFFEA7E5D"
    DATA "CadetBlue=&HFF5F9EA0"
    DATA "Canary=&HFFFFFF99"
    DATA "CaribbeanGreen=&HFF1CD3A2"
    DATA "CarnationPink=&HFFFFAACC"
    DATA "Cerise=&HFFDD4492"
    DATA "Cerulean=&HFF1DACD6"
    DATA "ChartReuse=&HFF7FFF00"
    DATA "Chestnut=&HFFBC5D58"
    DATA "Chocolate=&HFFD2691E"
    DATA "Copper=&HFFDD9475"
    DATA "Coral=&HFFFF7F50"
    DATA "Cornflower=&HFF9ACEEB"
    DATA "CornflowerBlue=&HFF6495ED"
    DATA "Cornsilk=&HFFFFF8DC"
    DATA "CottonCandy=&HFFFFBCD9"
    DATA "CrayolaAquamarine=&HFF78DBE2"
    DATA "CrayolaBlue=&HFF1F75FE"
    DATA "CrayolaBlueViolet=&HFF7366BD"
    DATA "CrayolaBrown=&HFFB4674D"
    DATA "CrayolaCadetBlue=&HFFB0B7C6"
    DATA "CrayolaForestGreen=&HFF6DAE81"
    DATA "CrayolaGold=&HFFE7C697"
    DATA "CrayolaGoldenrod=&HFFFCD975"
    DATA "CrayolaGray=&HFF95918C"
    DATA "CrayolaGreen=&HFF1CAC78"
    DATA "CrayolaGreenYellow=&HFFF0E891"
    DATA "CrayolaIndigo=&HFF5D76CB"
    DATA "CrayolaLavender=&HFFFCB4D5"
    DATA "CrayolaMagenta=&HFFF664AF"
    DATA "CrayolaMaroon=&HFFC8385A"
    DATA "CrayolaMidnightBlue=&HFF1A4876"
    DATA "CrayolaOrange=&HFFFF7538"
    DATA "CrayolaOrangeRed=&HFFFF2B2B"
    DATA "CrayolaOrchid=&HFFE6A8D7"
    DATA "CrayolaPlum=&HFF8E4585"
    DATA "CrayolaRed=&HFFEE204D"
    DATA "CrayolaSalmon=&HFFFF9BAA"
    DATA "CrayolaSeaGreen=&HFF9FE2BF"
    DATA "CrayolaSilver=&HFFCDC5C2"
    DATA "CrayolaSkyBlue=&HFF80DAEB"
    DATA "CrayolaSpringGreen=&HFFECEABE"
    DATA "CrayolaTann=&HFFFAA76C"
    DATA "CrayolaThistle=&HFFEBC7DF"
    DATA "CrayolaViolet=&HFF926EAE"
    DATA "CrayolaYellow=&HFFFCE883"
    DATA "CrayolaYellowGreen=&HFFC5E384"
    DATA "Crimson=&HFFDC143C"
    DATA "Cyan=&HFF00FFFF"
    DATA "Dandelion=&HFFFDDB6D"
    DATA "DarkBlue=&HFF00008B"
    DATA "DarkCyan=&HFF008B8B"
    DATA "DarkGoldenRod=&HFFB8860B"
    DATA "DarkGray=&HFFA9A9A9"
    DATA "DarkGreen=&HFF006400"
    DATA "DarkKhaki=&HFFBDB76B"
    DATA "DarkMagenta=&HFF8B008B"
    DATA "DarkOliveGreen=&HFF556B2F"
    DATA "DarkOrange=&HFFFF8C00"
    DATA "DarkOrchid=&HFF9932CC"
    DATA "DarkRed=&HFF8B0000"
    DATA "DarkSalmon=&HFFE9967A"
    DATA "DarkSeaGreen=&HFF8FBC8F"
    DATA "DarkSlateBlue=&HFF483D8B"
    DATA "DarkSlateGray=&HFF2F4F4F"
    DATA "DarkTurquoise=&HFF00CED1"
    DATA "DarkViolet=&HFF9400D3"
    DATA "DeepPink=&HFFFF1493"
    DATA "DeepSkyBlue=&HFF00BFFF"
    DATA "Denim=&HFF2B6CC4"
    DATA "DesertSand=&HFFEFCDB8"
    DATA "DimGray=&HFF696969"
    DATA "DodgerBlue=&HFF1E90FF"
    DATA "Eggplant=&HFF6E5160"
    DATA "ElectricLime=&HFFCEFF1D"
    DATA "Fern=&HFF71BC78"
    DATA "FireBrick=&HFFB22222"
    DATA "Floralwhite=&HFFFFFAF0"
    DATA "ForestGreen=&HFF228B22"
    DATA "Fuchsia=&HFFC364C5"
    DATA "FuzzyWuzzy=&HFFCC6666"
    DATA "Gainsboro=&HFFDCDCDC"
    DATA "GhostWhite=&HFFF8F8FF"
    DATA "Gold=&HFFFFD700"
    DATA "GoldenRod=&HFFDAA520"
    DATA "GrannySmithApple=&HFFA8E4A0"
    DATA "Gray=&HFF808080"
    DATA "Green=&HFF008000"
    DATA "GreenBlue=&HFF1164B4"
    DATA "GreenYellow=&HFFADFF2F"
    DATA "HoneyDew=&HFFF0FFF0"
    DATA "HotMagenta=&HFFFF1DCE"
    DATA "HotPink=&HFFFF69B4"
    DATA "Inchworm=&HFFB2EC5D"
    DATA "IndianRed=&HFFCD5C5C"
    DATA "Indigo=&HFF4B0082"
    DATA "Ivory=&HFFFFFFF0"
    DATA "JazzberryJam=&HFFCA3767"
    DATA "JungleGreen=&HFF3BB08F"
    DATA "Khaki=&HFFF0E68C"
    DATA "LaserLemon=&HFFFEFE22"
    DATA "Lavender=&HFFE6E6FA"
    DATA "LavenderBlush=&HFFFFF0F5"
    DATA "LawnGreen=&HFF7CFC00"
    DATA "LemonChiffon=&HFFFFFACD"
    DATA "LemonYellow=&HFFFFF44F"
    DATA "LightBlue=&HFFADD8E6"
    DATA "LightCoral=&HFFF08080"
    DATA "LightCyan=&HFFE0FFFF"
    DATA "LightGoldenRodYellow=&HFFFAFAD2"
    DATA "LightGray=&HFFD3D3D3"
    DATA "LightGreen=&HFF90EE90"
    DATA "LightPink=&HFFFFB6C1"
    DATA "LightSalmon=&HFFFFA07A"
    DATA "LightSeaGreen=&HFF20B2AA"
    DATA "LightSkyBlue=&HFF87CEFA"
    DATA "LightSlateGray=&HFF778899"
    DATA "LightSteelBlue=&HFFB0C4DE"
    DATA "LightYellow=&HFFFFFFE0"
    DATA "Lime=&HFF00FF00"
    DATA "LimeGreen=&HFF32CD32"
    DATA "Linen=&HFFFAF0E6"
    DATA "MacaroniAndCheese=&HFFFFBD88"
    DATA "Magenta=&HFFFF00FF"
    DATA "MagicMint=&HFFAAF0D1"
    DATA "Mahogany=&HFFCD4A4C"
    DATA "Maize=&HFFEDD19C"
    DATA "Manatee=&HFF979AAA"
    DATA "MangoTango=&HFFFF8243"
    DATA "Maroon=&HFF800000"
    DATA "Mauvelous=&HFFEF98AA"
    DATA "MediumAquamarine=&HFF66CDAA"
    DATA "MediumBlue=&HFF0000CD"
    DATA "MediumOrchid=&HFFBA55D3"
    DATA "MediumPurple=&HFF9370DB"
    DATA "MediumSeaGreen=&HFF3CB371"
    DATA "MediumSlateBlue=&HFF7B68EE"
    DATA "MediumSpringGreen=&HFF00FA9A"
    DATA "MediumTurquoise=&HFF48D1CC"
    DATA "MediumVioletRed=&HFFC71585"
    DATA "Melon=&HFFFDBCB4"
    DATA "MidnightBlue=&HFF191970"
    DATA "MintCream=&HFFF5FFFA"
    DATA "MistyRose=&HFFFFE4E1"
    DATA "Moccasin=&HFFFFE4B5"
    DATA "MountainMeadow=&HFF30BA8F"
    DATA "Mulberry=&HFFC54B8C"
    DATA "NavajoWhite=&HFFFFDEAD"
    DATA "Navy=&HFF000080"
    DATA "NavyBlue=&HFF1974D2"
    DATA "NeonCarrot=&HFFFFA343"
    DATA "OldLace=&HFFFDF5E6"
    DATA "Olive=&HFF808000"
    DATA "OliveDrab=&HFF6B8E23"
    DATA "OliveGreen=&HFFBAB86C"
    DATA "Orange=&HFFFFA500"
    DATA "OrangeRed=&HFFFF4500"
    DATA "OrangeYellow=&HFFF8D568"
    DATA "Orchid=&HFFDA70D6"
    DATA "OuterSpace=&HFF414A4C"
    DATA "OutrageousOrange=&HFFFF6E4A"
    DATA "PacificBlue=&HFF1CA9C9"
    DATA "PaleGoldenRod=&HFFEEE8AA"
    DATA "PaleGreen=&HFF98FB98"
    DATA "PaleTurquoise=&HFFAFEEEE"
    DATA "PaleVioletRed=&HFFDB7093"
    DATA "PapayaWhip=&HFFFFEFD5"
    DATA "Peach=&HFFFFCFAB"
    DATA "PeachPuff=&HFFFFDAB9"
    DATA "Periwinkle=&HFFC5D0E6"
    DATA "Peru=&HFFCD853F"
    DATA "PiggyPink=&HFFFDDDE6"
    DATA "PineGreen=&HFF158078"
    DATA "Pink=&HFFFFC0CB"
    DATA "PinkFlamingo=&HFFFC74FD"
    DATA "PinkSherbet=&HFFF78FA7"
    DATA "Plum=&HFFDDA0DD"
    DATA "PowderBlue=&HFFB0E0E6"
    DATA "Purple=&HFF800080"
    DATA "PurpleHeart=&HFF7442C8"
    DATA "PurpleMountainsMajesty=&HFF9D81BA"
    DATA "PurplePizzazz=&HFFFE4EDA"
    DATA "RadicalRed=&HFFFF496C"
    DATA "RawSienna=&HFFD68A59"
    DATA "RawUmber=&HFF714B23"
    DATA "RazzleDazzleRose=&HFFFF48D0"
    DATA "Razzmatazz=&HFFE3256B"
    DATA "Red=&HFFFF0000"
    DATA "RedOrange=&HFFFF5349"
    DATA "RedViolet=&HFFC0448F"
    DATA "RobinsEggBlue=&HFF1FCECB"
    DATA "RosyBrown=&HFFBC8F8F"
    DATA "RoyalBlue=&HFF4169E1"
    DATA "RoyalPurple=&HFF7851A9"
    DATA "SaddleBrown=&HFF8B4513"
    DATA "Salmon=&HFFFA8072"
    DATA "SandyBrown=&HFFF4A460"
    DATA "Scarlet=&HFFFC2847"
    DATA "ScreaminGreen=&HFF76FF7A"
    DATA "SeaGreen=&HFF2E8B57"
    DATA "SeaShell=&HFFFFF5EE"
    DATA "Sepia=&HFFA5694F"
    DATA "Shadow=&HFF8A795D"
    DATA "Shamrock=&HFF45CEA2"
    DATA "ShockingPink=&HFFFB7EFD"
    DATA "Sienna=&HFFA0522D"
    DATA "Silver=&HFFC0C0C0"
    DATA "SkyBlue=&HFF87CEEB"
    DATA "SlateBlue=&HFF6A5ACD"
    DATA "SlateGray=&HFF708090"
    DATA "Snow=&HFFFFFAFA"
    DATA "SpringGreen=&HFF00FF7F"
    DATA "SteelBlue=&HFF4682B4"
    DATA "Sunglow=&HFFFFCF48"
    DATA "SunsetOrange=&HFFFD5E53"
    DATA "Tann=&HFFD2B48C"
    DATA "Teal=&HFF008080"
    DATA "TealBlue=&HFF18A7B5"
    DATA "Thistle=&HFFD8BFD8"
    DATA "TickleMePink=&HFFFC89AC"
    DATA "Timberwolf=&HFFDBD7D2"
    DATA "Tomato=&HFFFF6347"
    DATA "TropicalRainForest=&HFF17806D"
    DATA "Tumbleweed=&HFFDEAA88"
    DATA "Turquoise=&HFF40E0D0"
    DATA "TurquoiseBlue=&HFF77DDE7"
    DATA "UnmellowYellow=&HFFFFFF66"
    DATA "Violet=&HFFEE82EE"
    DATA "VioletBlue=&HFF324AB2"
    DATA "VioletRed=&HFFF75394"
    DATA "VividTangerine=&HFFFFA089"
    DATA "VividViolet=&HFF8F509D"
    DATA "Wheat=&HFFF5DEB3"
    DATA "White=&HFFFFFFFF"
    DATA "Whitesmoke=&HFFF5F5F5"
    DATA "WildBlueYonder=&HFFA2ADD0"
    DATA "WildStrawberry=&HFFFF43A4"
    DATA "WildWatermelon=&HFFFC6C85"
    DATA "Wisteria=&HFFCDA4DE"
    DATA "Yellow=&HFFFFFF00"
    DATA "YellowGreen=&HFF9ACD32"
    DATA "YellowOrange=&HFFFFAE42"
    DATA "END"
END FUNCTION

