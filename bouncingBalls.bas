CONST true = -1, false = NOT true
CONST gravity = .01
CONST airResistance = .001
CONST ballSize = 100

RANDOMIZE TIMER

'create ball image  ---------------------------------------------------------------------------
DIM canvas AS LONG, texture AS LONG
DIM SHARED ballImage(1 TO 3) AS LONG
DIM lastBounce AS SINGLE

canvas = _NEWIMAGE(250, 250, 32)
texture = _NEWIMAGE(1, 255, 32)

FOR thisBall = 1 TO 3
    _DEST texture
    FOR i = 0 TO 254
        SELECT CASE thisBall
            CASE 1
                PSET (0, i), _RGB32(i, 20, 20)
            CASE 2
                PSET (0, i), _RGB32(20, i, 20)
            CASE 3
                PSET (0, i), _RGB32(20, 20, i)
        END SELECT
    NEXT

    _DEST canvas
    CLS
    _MAPTRIANGLE (0, 0)-(0, 0)-(0, 254), texture TO(0, 0)-(0, _HEIGHT)-(_WIDTH, 0)
    _MAPTRIANGLE (0, 0)-(0, 0)-(0, 254), texture TO(0, _HEIGHT)-(_WIDTH, _HEIGHT)-(_WIDTH, 0)
    CIRCLE (_WIDTH / 2, _HEIGHT / 2), ballSize, _RGB32(255, 255, 255)
    PAINT (0, 0), _RGB32(255, 255, 255)
    CIRCLE (_WIDTH / 2, _HEIGHT / 2), ballSize, _RGB32(0, 0, 0)
    PAINT (0, 0), _RGB32(0, 0, 0)
    _CLEARCOLOR _RGB32(0, 0, 0)

    ballImage(thisBall) = _COPYIMAGE(canvas&)
NEXT thisBall

_FREEIMAGE texture


_FREEIMAGE canvas&
'ball image created --------------------------------------------------------------------------

canvas = _NEWIMAGE(600, 600, 32)
SCREEN canvas

COLOR , 0

TYPE newBall
    x AS SINGLE
    y AS SINGLE
    lastY AS SINGLE
    lastX AS SINGLE
    xv AS SINGLE
    yv AS SINGLE
    xacc AS SINGLE
    yacc AS SINGLE
    size AS INTEGER
    moving AS _BYTE
    vdistortion AS SINGLE
    image AS LONG
END TYPE

REDIM SHARED ball(0) AS newBall
DIM SHARED totalBalls AS LONG, soundON AS _BYTE
DIM addingBall AS _BYTE


soundON = true
SaveSoundFile
DIM SHARED bounce AS LONG
bounce = _SNDOPEN("Jump-SoundBible.com-1007297584.ogg")

DO
    CLS
    DO WHILE _MOUSEINPUT
        IF _MOUSEBUTTON(1) THEN
            IF _MOUSEX <= 50 AND _MOUSEY <= 50 THEN
                IF NOT togglingSound AND NOT addingBall THEN
                    togglingSound = true
                    soundON = NOT soundON
                    EXIT DO
                END IF
            ELSE
                IF NOT togglingSound AND NOT addingBall THEN
                    addingBall = true
                    addBall _MOUSEX, _MOUSEY
                    EXIT DO
                END IF
            END IF
        ELSE
            addingBall = false
            togglingSound = false
        END IF
    LOOP
    moveBalls
    showBalls

    IF _MOUSEX <= 50 AND _MOUSEY <= 50 THEN
        LINE (0, 0)-(50, 50), _RGB32(80, 80, 80), BF
    END IF

    IF bounce > 0 THEN
        IF soundON THEN
            DRAW "B C4294967295 M6,19 M6,39 M11,39 M13,18 M8,19 M13,18 M13,23 M26,9 M24,13 M25,42 M27,43 M13,32 B M29,16 M45,7 B M29,24 M45,23 B M30,32 M44,36 B M32,42 M43,45"
        ELSE
            DRAW "B C4294967295 M6,19 M6,39 M11,39 M13,18 M8,19 M13,18 M13,23 M26,9 M24,13 M25,42 M27,43 M13,32"
        END IF
    END IF

    LOCATE 5, 1
    IF totalBalls = 0 THEN PRINT "Click around to drop balls in the court..." ELSE PRINT totalBalls
    _DISPLAY
    _LIMIT 30
LOOP

SUB moveBalls
    DIM i AS LONG
    FOR i = 1 TO totalBalls
        IF ball(i).moving THEN
            'horizontal movement:
            ball(i).xacc = ball(i).xacc + wind
            ball(i).xv = ball(i).xv + ball(i).xacc
            ball(i).x = ball(i).x + ball(i).xv
            IF ball(i).xv > 0 THEN
                ball(i).xv = ball(i).xv - airResistance
            ELSE
                ball(i).xv = ball(i).xv + airResistance
            END IF

            'vertical movement:
            ball(i).yacc = ball(i).yacc + gravity
            ball(i).yv = ball(i).yv + ball(i).yacc
            ball(i).y = ball(i).y + ball(i).yv
            IF ball(i).y + ball(i).size / 2 >= _HEIGHT - ball(i).size / 2 THEN
                ball(i).y = (_HEIGHT - ball(i).size / 2) - ball(i).size / 2
                ball(i).yv = -ball(i).yv
                ball(i).vdistortion = INT(ABS(ball(i).yv))
                IF soundON AND bounce > 0 AND TIMER - lastBounce > 1 THEN
                    _SNDPLAYCOPY bounce, .1
                    lastBounce = TIMER
                END IF
            END IF
            IF ball(i).yv > 0 THEN
                ball(i).yv = ball(i).yv - airResistance
            ELSE
                ball(i).yv = ball(i).yv + airResistance
            END IF


            'collision detection:
            DIM j AS LONG, theDist AS SINGLE
            FOR j = 1 TO UBOUND(ball)
                IF j = i THEN _CONTINUE
                theDist = dist(ball(i).x, ball(i).y, ball(j).x, ball(j).y)
                IF theDist < ball(i).size * 2 THEN
                    'touched another ball: forces interact
                    ball(j).moving = true
                    IF ball(j).x < ball(i).x THEN
                        ball(j).xv = ball(j).xv - theDist / 100
                    ELSE
                        ball(j).xv = ball(j).xv + theDist / 100
                    END IF

                    IF ball(j).y < ball(i).y THEN
                        ball(j).yv = ball(j).yv - theDist / 100
                    ELSE
                        ball(i).vdistortion = INT(ABS(ball(i).yv) / 2)
                        ball(j).yv = ball(j).yv + theDist / 100
                    END IF
                END IF
            NEXT

            'check if this ball didn't move since the last iteration,
            'in which case we mark it as not moving:
            IF ball(i).y = ball(i).lastY AND ball(i).x = ball(i).lastX THEN
                ball(i).moving = false
            ELSE
                ball(i).lastY = ball(i).y
                ball(i).lastX = ball(i).x
            END IF

            'stop movement if offscreen
            IF ball(i).x - ball(i).size > _WIDTH OR ball(i).x + ball(i).size < 0 THEN
                ball(i).moving = false
            END IF
        ELSE
            'in case another ball affected this one, it's set as moving again:
            IF ball(i).y <> ball(i).lastY OR ball(i).x <> ball(i).lastX THEN
                ball(i).moving = true
            END IF
        END IF
    NEXT
END SUB

SUB showBalls
    DIM i AS LONG
    FOR i = 1 TO totalBalls
        _PUTIMAGE (ball(i).x - _WIDTH(ballImage(ball(i).image)) / 2, ball(i).y - (_HEIGHT(ballImage(ball(i).image)) / 2) + ball(i).vdistortion * 2)-(ball(i).x + _WIDTH(ballImage(ball(i).image)) / 2, ball(i).y + (_HEIGHT(ballImage(ball(i).image)) / 2)), ballImage(ball(i).image)
        IF ball(i).vdistortion THEN
            ball(i).vdistortion = ball(i).vdistortion - 2
            IF ball(i).vdistortion < 0 THEN ball(i).vdistortion = 0
        END IF
        _PRINTSTRING (ball(i).x, ball(i).y + ball(i).vdistortion), STR$(ball(i).moving)
    NEXT
END SUB

SUB addBall (x, y)
    DIM i AS LONG

    FOR i = 1 TO UBOUND(ball)
        IF ball(i).x - ball(i).size > _WIDTH OR ball(i).x + ball(i).size < 0 THEN
            'if ball(i) is offscreen, let's reuse its slot
            EXIT FOR
        END IF
    NEXT

    IF i > UBOUND(ball) THEN
        totalBalls = totalBalls + 1
        i = totalBalls
        IF totalBalls > UBOUND(ball) THEN
            REDIM _PRESERVE ball(UBOUND(ball) + 99) AS newBall
        END IF
    END IF

    ball(i).x = x
    ball(i).y = y
    ball(i).xacc = 0
    ball(i).yacc = 1
    ball(i).lastX = -1
    ball(i).lastY = -1
    ball(i).vdistortion = 0
    ball(i).yv = 0
    ball(i).xv = 0
    ball(i).size = ballSize
    ball(i).moving = true
    ball(i).image = _CEIL(RND * 3)
END SUB

FUNCTION dist! (x1!, y1!, x2!, y2!)
    dist! = SQR((x2! - x1!) ^ 2 + (y2! - y1!) ^ 2)
END FUNCTION

SUB SaveSoundFile
    'Data generated from "Jump-SoundBible.com-1007297584.ogg" by
    'Dav's BASFILE.BAS v0.10 - http://www.qbasicnews.com/dav/files/basfile.bas
    A$ = ""
    A$ = A$ + "?MfIC1P0000000000009B_XD00000@HZ2ZJ0N4PM_9WHY=7000001@4[0000"
    A$ = A$ + "d7000@O0000m100^1ldIW=50000000000000T8mRB500000jK?Pl?\eooooo"
    A$ = A$ + "ooooooooooooX?PM_9WHY=G;0000HU6LXibCbM68\UVHFmVLRUfLPT48b0C<"
    A$ = A$ + "`4C<`438X<eHX5FMVEVKeMfIUAG:10000X1000@A>=dC4ETDm@eMY=7MUAfE"
    A$ = A$ + "QIGIPlTK\UVKU5@1fmVLRUfLY8d@F5008000043CPD<P@3IE0004000HTTR3"
    A$ = A$ + "CJFBYD:UQRBNHB9B9UBYDF<<9R9U9F<6SaH<6SaH<6SaH<6SP@3IE000400P"
    A$ = A$ + "XTPSSJNBZiL>WQa9>:7XiTVChL:87XHDPWC22G_9SiVYdJjJ^iL:UP@3IE00"
    A$ = A$ + "08000QD85BQD85BQD86RQH86RQH87bQL87bYL:W2ZP:X2ZP<83bP<9CjT>YC"
    A$ = A$ + "jT>ZSjX>ZS2]@;d2]@[d:aD<EKeH^f[1MagL>WciL>WciL>WciL22=TE1008"
    A$ = A$ + "00012I@6T1Q@84BQD85RYH:VbYP<838d@F500020020000`AABABaBababAc"
    A$ = A$ + "ACbCbcBDCDCdcDdDDeDEEEEEeeeEfEfefEgefeGFHFhFhfGFhFhFHGHGgGHH"
    A$ = A$ + "HHHHHHHHHHHHhggggggggg78d@F500B000j8iHihY8Z8J8Zhi8j04J8[200I"
    A$ = A$ + "000100B2B:B:B>JBVJVJ^VfVfRfZfffbbbbbbb0Q6bZ000@00@00000000JJ"
    A$ = A$ + "JJJJJJJJJJJJJJJJJJJJJJJJJJFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
    A$ = A$ + "FFFFFFFFFFFFFFFF0Q6bZ00@200@7777777959597;7;7P@3IE008300800@"
    A$ = A$ + "BaBabAcAcAcacacacacAdADbDbDcdcd38d@F500020020000000@a`AaaaAb"
    A$ = A$ + "ACbCBebdbEcEcececedeeeeEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
    A$ = A$ + "EEEEEEEEE58d@F500@0004BWVIYJ0R`<@668d@F500800006QR`@<P@3IE00"
    A$ = A$ + "0@000PHXT3RV@[il=WS3JF>XYBaVC7LRD]i9iV:VK>WciL>W\iL6SciL>WRb"
    A$ = A$ + "IF<XI2]VciLB<XIYPV9dJ>Wci9aV7dJZB[iL>WaiLjPaI46WciLJB[i1YV=F"
    A$ = A$ + "K>WcI1]VVSJ^D\iL>W8UKNB]iBeVciL>WciL>WciL>WcYj5W>7L>QciL>WXf"
    A$ = A$ + "K^F^9d5WciLnTaYk=W@hL>WciL>WciL>WciL>WP@3IE000400@@HHSQaM:88"
    A$ = A$ + "miX1RAA8V6bTN@gS><9XaPL:TjAS>JTBY>8DBUa9UBWP@3IE0008000Q@85B"
    A$ = A$ + "QD85BQD85BQD85RQH86RQL:WbYP:XBZT:ZRbX<;cb\<;cb\<;cj`>[cj`><4"
    A$ = A$ + "3a@<d:]B\DCeF=FSeJ^WciJ>8]FYeJ]F[D:UBYD:U22=TE100800012I@6T1"
    A$ = A$ + "ID85BQD86RYL:WbYP:X28d@F500020020000`CbcAdAdAdAdAdAdAdAdAdac"
    A$ = A$ + "acADBDBDBDBdbdbDcdCEDEeEfeFFGFgfgFHGHGggGgggGghGGHHIIIIIIIII"
    A$ = A$ + "IIIIIIIIIIII98d@F500P0000842Q@85BQD85BYH<6caL>XC2U@P@3IE0008"
    A$ = A$ + "00800000757577979799;9;9=9=;=;?=?=?=A?AAAACCCEAGAGAMCKAICICG"
    A$ = A$ + "CGCICGEIEKGIIKKIKMKOIIKOOOOOOOOOOOOOOOOOOOMMP@3IE008100XSTST"
    A$ = A$ + "RTRTRTSSSSTT4@XQ\:00T100400XXhXhhhh89999I9Y9iIiI9ZIZIjIjY:Z2"
    A$ = A$ + "4J8[200010010000000XXYhYHZhY8Zhi8j8:9JIJ9ZYZi::K:kjjjjjjjjjj"
    A$ = A$ + "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj24J8[2009000MTLTLTLTDTD"
    A$ = A$ + "TDTLTL02=TE10P<00P00073739597;;;==?=?=?=A?A?A?C?EAGAGP@3IE00"
    A$ = A$ + "0800800000000393;5;7=7=9A9E;E;E=E;E;EAE?EEEEEEEEEEEEEEEEEEEE"
    A$ = A$ + "EEEEEEEEEEEEEEEEEEEEEEEEECCCCCCP@3IU00@6000I1O?842Q3SB]@`44J"
    A$ = A$ + "<7T1YB>X1UDYEKmPV3a<<VckEBXT9YD?HiL@43ilP4baD<VBY]B;UA=613di"
    A$ = A$ + "L7Gi@@P@3I51045000H<663aH8Wc9U<Y4iL<Yd9U8WcAU>Yd9UB;FRa<YDR]"
    A$ = A$ + "B<6iL>Zd9Y<YDRaB;fAYB<FR]20002`10080;4:d@FA00A100863BY@:5BYD"
    A$ = A$ + ">WRi@:UbaD>7BYD>VbiD>W32M@XbaH@W32A:UbaD>WbiL@8c1E>W32M@X000"
    A$ = A$ + "P0L0002`2Q2=TE40@L20P397??9=;AA9;=AA?AAIG?ACGI9==CA=AAEE;?AE"
    A$ = A$ + "ECEEKKACEIK9==AA=A?EE=AAEEAECKICEEKK?CCKICEGMKAEEMKIKKOOGIKQ"
    A$ = A$ + "O?CCIIAEEKMCEGKMGKIOOIKMMQ9==CC=AAEE=AAEECGEMKCEGKK=AAGGAEEI"
    A$ = A$ + "IAEEIIEIIKQEIIMO;AAEE?ECIGAEEIIEIGOKEIIOOCGGMMEIIOOEIIOMKOQQ"
    A$ = A$ + "UKOOSRZZfjVb^njZbbnnfjfl]mm=:YYIJZ9:jZZ9:ZjJZZZKKZjJKK9:ZZ:Z"
    A$ = A$ + "Z:;kIZj:[:;;\[j:K[[9:Zj:ZZ:;;ZZ:;[:kjk[:;[K;ZZJ[[:;k[Kj:kk[k"
    A$ = A$ + "kS]\^_aYZZ^^Z\]_aZ\\_^^__BKMMOO?CCIICGEOMCEEOMIMOSbfj23SZZjj"
    A$ = A$ + "Zbbn6[bbn2knnXKlCHDEEGGEfEHGEffGHgHW`^__ab\^=SKOOUSKOMUUOSUl"
    A$ = A$ + "5R[]]``\_=SKOMSn6o:37;3iIJJK;jZZ[KZjZ;<[[KlKk[K<<ZZj[[:;cGeE"
    A$ = A$ + "fGGggW`^^_a`X[Z^`Z\\__Z]\__^^_ab_a?^ffl]mmI<K[kChg8OOQUbff2]"
    A$ = A$ + "5nYL[[K\<lKT^b?20006`10080CX<@Q6b:208>10P1QL>5C1Q:532M@8UjP@"
    A$ = A$ + "9EaH@8ciTB5c1U@YdJQ@9eZH<8DiHB8ciTBX4JY@YdBM@8U2UB[5:UF;eJaJ"
    A$ = A$ + ":eRa>8TBQBYU2UB[UJYH<eJaH5S1Q<7C:I<WD2UB;5:UF;ciTBW3BY>8TBUD"
    A$ = A$ + "Ze:UD;FaHB93jXBW3:YBZ4CUDZe2UB[E:YH\TBaF[5SeF;F[QBYe2UB[EBYH"
    A$ = A$ + "<eBeF;6[e:632I>VDbH>Y4:UF:D:YF5S9U>XS:I>XT:YD\E:YD<ciTB74BY>"
    A$ = A$ + "8TBUD9f:YD[5:UF[TBaFXDJaF\E[YD[E3UB[EBYH\TBaH;fZeF\ESM@8U2UB"
    A$ = A$ + "[5:UF;eJeHZeRa@YdJUD:6;YD\eRaJ]eReJXDJ]@Z4KUBZ5CaF=fJaJ=eJaH"
    A$ = A$ + "Z5[eF<F[aH]fSeJ_WBYH<eBeH[5[iH]eSeJ=gkP@:5:UF;D:]FZeZaD[5[QB"
    A$ = A$ + "Ye:YB\5:YF\5KeJ[5Se@YdJUDZ5;YD<fR]J]5SeJZeRaF\E[YD;FSiJ?7KeH"
    A$ = A$ + "?eJaH;6[eF[E[aJ=WSeH_F000`0>0001H2U1:d@F900A10044RBaLBY1QL<W"
    A$ = A$ + "SB984SiPDZbaP@YdJE<7D:UF[ciTB;5SM>XDBYH\TB]F<F[UDZeRaJ]000P2"
    A$ = A$ + "L0002`6dDR57P2=TE20@D000RaP@<64J@6UbaP@S1YD<64RD:6ciTBTBaH>W"
    A$ = A$ + "DbL<WC2YD6ciL@9U2Q@YT:]D84:UD:e:000X0700P0\1=UHa1X@3I5104500"
    A$ = A$ + "0H<863aH8Xc1Q<Y4iP<Xd1Q684BU>YTAUBYEJ]<YDJYB[51Q>Y4BY<ZDJ]BZ"
    A$ = A$ + "U9YB[EJU200`>`100k0;4:d@F900i10086SBaH>WcI@8UbaL>WcP@:5ciL>W"
    A$ = A$ + "RYH<W32Q@URaH>742Q<7ciP@842I<Wc1Q@84jL>842U@8diL@842Q@YciP@8"
    A$ = A$ + "D2UBWc1Q@8D:U200P:`10080KDT=WPA2Z@3IU00T7000H<:Uc9UDZAYH<8T:"
    A$ = A$ + "]FT2aH@XTJ]:6ciTB:5SE<Vc9UD;6kP@YTB]F]f1QB9UJ]J]D:YD\E[iLYDJ"
    A$ = A$ + "]H\FciD[5SeJ^fcYF;6[eL>g;00`M1700\3\AAfL269X2=TE20@N00032YD<"
    A$ = A$ + "6SaH8URaH<6Sa@:URaH<6SYH<6SaH<WCaH<6SaH>7SaH<7ciL>6SaH<WciL<"
    A$ = A$ + "6SaL>WciH<6SiL>WcaH<WciL>WSaH>WciL>W000X2L0002`65Ic9HTP:d@F9"
    A$ = A$ + "00i10004RD:UBYDJTBYD:UBYd8UBYD:UBYD:UBYD:UBYD:UBYD:UBYD:UBYD"
    A$ = A$ + ":UBYD:UBYD:UBYD:UBYD:UBYD:UBYD:UBYD:U@842Q@842Q2047_`10mI2KD"
    A$ = A$ + "T=WPA2Z@3IU00T:000H<:TC1MB8EJD:W32YB:UB=:Uc9QD:UB]:WC:YD[5Ka"
    A$ = A$ + "HUc9UDZeJaJ\C:YD;F[eJ>g9UD[5SeJ]V3YD<F[iJ?7dQDZ5[eL=WcmB[5[i"
    A$ = A$ + "L>g3nP9fReJ_gkiN@5SeL=Xk1Q@XRaJ>Wc1Q?h;00<92700a5\QE7QC:J\0;"
    A$ = A$ + "d@F500a00031044:J6000VP300@0F1k:cB[JSRKZCb;j32l9dA\ITQLYDa<i"
    A$ = A$ + "41m8e@]HUPMXE`=h50FXQ\B008300@PJ<GkaH=2aH>8EJiB5BYPB9f;E:Ub1"
    A$ = A$ + "QF^VYD8UbIiB7SYH<65[U@7BI@@[42M:5RXXFZe:Q>4b9YL<6KM:60000220"
    A$ = A$ + "034Q<CP0505HP<00>0Q4T20P2;`@73G4@0iB8S2<X`a4>WdY=00@@8b<49RH"
    A$ = A$ + "aP4CXJPR:V>0P5GPQl10b@S=BkR;P^<0G@GLG784221QPHa1@1T0>h4^QWh="
    A$ = A$ + "l4^1WP>5EZ32000000010P700PT=0R8RXI>>j`S?094A6QTB<i4D20000000"
    A$ = A$ + "80P?00PTD0R8RXI>>j`S?094A6QTB<i4D200000000000028P0000000@000"
    A$ = A$ + "0028?MfIC1000K3000000009B_XD20000\2W?W28GQ3<;3mo>l_3ogb<b4c<"
    A$ = A$ + "dH5Do?fonlO>o?do<mO=3o>O9\n\IOHcHB\^nodURbibiOn@mai3Nnck:S\X"
    A$ = A$ + "\X\X\8S\8S:;:7UA6I?Qem>PR>:QYiD?8oCUBOUQS7>]32;DV5`I3^LA9DXL"
    A$ = A$ + "MRmB8n1NjcROPW?E7C2aNMmoYkRgMTIHjgmLiXGWc7^jIHd[ci9SA987PS:<"
    A$ = A$ + "feg?hkN8kZigkIm_i`T9^nC_6\KSkF8\1`]Oo1gLP1COmho9VSN=lLIEna[Q"
    A$ = A$ + "eLo7h44lhgo2?4ae?9HlciZ>;=oo4`PCYFg95XifmSfGAPR0gKUbIcV00PZ3"
    A$ = A$ + "ghlekVhM9ThDT0P3P^YGS9A:SB0:00X;O:13dcionF]_GYVn\e3lYZNojS4n"
    A$ = A$ + "<O^Qog>E\KgS^AONZ<7fDFQJ_oOdfTJBb\ZIF4kgd?Ua2TK8FYcL;_hUQaHb"
    A$ = A$ + "Ukm9KJibK[NJO8[<B7?\Efkoenc<8l_iXVUn]jSln\o]PY;\nnSm7Mh8]iQ;"
    A$ = A$ + "kn_hebBWRYW^_@^nlo6[>AKhObOi_EF00\7T_9aR\U3nM\bUGdd6@7@gc1`I"
    A$ = A$ + "SN207X30N]Og1o9QZ<ac=i@IC00ho7f[6E6P<DPcDXc3000k7B20Nki`GGSK"
    A$ = A$ + "n9ocGe?9[@[F7<Y`E`o5WW4fZhIUfB7e:^X_G9lNd:bHYVGOVMnCMha`db9K"
    A$ = A$ + "diaV93=E51A2d?B?4TgF[4?l?ejF;KO:gG7<n9:=mkI5C4_O^]bmKBCW3EcQ"
    A$ = A$ + "FAZI>L:^NR^HWn79Je`C<G:=>e>=ROdN]QC0mOAnCkAK0Zl`DdLk;0mVD@:J"
    A$ = A$ + ">77MM6ZXP8Z2mKnTj>dd^Sh:kF5>SOmmXm0k_<U\BQd]OhgnMFngdE3D67;G"
    A$ = A$ + "f400:V]GenX300I0>@Jb4Z<09G9X00`n0f03<OIgda>nkRegMXhM;fj3^L;W"
    A$ = A$ + "URE^o0YNk\hMkaNG:WT\b0^Z_]nLdiDE^NdkU3LX[aDnSCc2LYdiCFV>:9nb"
    A$ = A$ + "Ylg>LG=7EiPmi]=jcRfi=_iYWnhlTjCJlWZ[SBYDB3i5_nHC@Ce5_^LZ;PYf"
    A$ = A$ + "fooa:494]g`DYMZjZO<kAhjc76GJ=]bc60@nYgG@MfDZEP9aeKnWj71U<5<["
    A$ = A$ + "C;j_HOeQ_VkeJfcjCFomReFOK\KL^?AYB]R5TVSLUE0[KooJlo858DGCBW1i"
    A$ = A$ + "lc9jH?hMjJA;797D@N37]A`0dX;KI]\3jLgIUDT6N_50N^O?mo9BYbV`Lc:K"
    A$ = A$ + "200lnUmU3007X08L`1l@EYZ<ID00n1h5F\RW?e7ji_lR\Y_g`KWRH16HB_m`"
    A$ = A$ + "5f\oUJKfdn>FQj6[T3jMUn>ElU;]Edd\RJCUG<:4Ro:9X=W[TF:jHS1[l:B="
    A$ = A$ + "E9T:>H52SGkN_3COl7ek`dI>d?a[KfcblT;;^a:okC=8IEldlmAAbn`l3K<a"
    A$ = A$ + "DGHZ9g4bFS=K:LLoI<gFhVi2aG5?JRj?;U75mQH>:eCEE_JE\V\m6JEShU5Q"
    A$ = A$ + "jiTT<lVN:iFNgObM[<9^Zm9^S=[\EQ9eoEi7j^B_S]<YQ`?cAYkAH04^o5fN"
    A$ = A$ + "Ve6kNWN8i@B[\X:id7=<^amU60_]dcg1QQfO:h8AI0P=kgMaOBi2?clL;>GR"
    A$ = A$ + "7IC00X_fn^Wn>d9kl]TjPSD7D8m3D8gL9]A1@f4XZ@L<00`??a>`Abfk2Vo;"
    A$ = A$ + "ngRBo`e>kFiOh7L<iCm_Uh_n:]^77^aOnjDRUWhbgLbMChSSMocSZGiilS>K"
    A$ = A$ + "gc<MlXMkS7SLinFmgW;nce8neR?lHXW>YOjMLY\T?b?nJaMm<k;II?Z_Yoof"
    A$ = A$ + "7ORoliUHS?iiMP47Q@Oje3HgThI2[>@;B@LX84Vi2MPW]HfUcCbnjnbjjY5i"
    A$ = A$ + "_ao>]Hb\ZIAICck8M?k_SeUNTO;<eRX;4OW9iom:LKM]ALgBid@eHF1cnL0J"
    A$ = A$ + "jZSlCJP[A0NelTA@HIR=DV<^fd=KgKgJM3S8`LKdo\8J?8l=<I6[jI;H_Ek5"
    A$ = A$ + "Uin[eY?U<EYk`fi^dcl0P10e2>n;PIa9a@UlV10d:2n`0`M^Qc:?X6OV?4cm"
    A$ = A$ + "J^ART3VC5fNEcbco1?U5DMgNUSiFfG0e2>m_0Ti7fJ3cF0\D1O60JMLXT297"
    A$ = A$ + "Al\ccm:nQP7Rfc_HZe]Y>EgZbR6Ee=5B:^RVPb]PkO2TWc6KGbF0dT3^0@Gi"
    A$ = A$ + "\F?<6K9KJ0Y_ZRG7?cADfRNRj;WOlKKcG^bn`ja^a20a2fn=8?C9[fO[F0\<"
    A$ = A$ + "@iW0kW6Z<=HURj1g4U??mS>Oa3@YL=eNFNi\;3iVR7_OVIdk553e2fmC0Ti?"
    A$ = A$ + "<LHJ60TJ6hABPYMK^e3S_;HffZ@SDDk12NdXXkB>hHiWEETF:Wmm8?Y6]6N0"
    A$ = A$ + "\;hkOZCNZ6Z5k0Dlfn]mQ?KD=Z8f_NmJGO9_U3<DlK[0hkT@`CN1?NW\oKHb"
    A$ = A$ + "b:Fjd_Q>lSZm5YbmlJNK[chW_9iVolf`dhONo^g[d=O7J;Fj95X[FS1i2nnW"
    A$ = A$ + "4`RSQY>0iQbjAgnG_NHHl`iJ_RYgGZkQP]]0hQ16K5GIIkJInRR8hhoOLj8J"
    A$ = A$ + "8i3@H[cfgMhYm1BNd^_7_Mm?MHmdgmf\ogmiF3AmQYWnM1neHI4[nDG[Q0OK"
    A$ = A$ + "A0000Pcn]ZblWQN]Y1L`QZQYYS63gnj]bWL?750P307<cj0e0Pb200hi4fN2"
    A$ = A$ + "hY900LS=9\\biNLZocSgl`k7eoeko?9kFoncNj;GN1?k\[<OOGH?Ok_UJRH>"
    A$ = A$ + "jgM9E^7H[YnFWmJEnD9mnTWJ:We[^iOM3adE\KnMWNLkM4_J=oioOgUlMXg_"
    A$ = A$ + "K?o9KZ=_NU_:oeV?^48jfhTZoR[o5HHUU3oX]S9QZfG^ln_UDohY;VFi\E>B"
    A$ = A$ + "`H]^o^nGK\fOo_X^IKkHke>]IU`EXReEg5jRZhJ5B^Tj_K:iM31U^MCG>KNW"
    A$ = A$ + "KiTKa1eJ6GLbKj[RYaeod\<nj4E]RR_:>5C2H:Fm\Yi@CoSom;8jfNm1dAog"
    A$ = A$ + "1MOBMXh`Ob3`SP5[X86oPf=5[GHAo]?[5WjVJ:GA[XIGg85YJL\cPBfnBSmh"
    A$ = A$ + "ZYj\JmJh6kF`lbDUMMQ2Zd\T^N4Pce220hcfMAo[VbjbX<79J67f20000`Jh"
    A$ = A$ + "5`C0D7@W1FbRSmR6?`Y3?=DXbX3EE9C600nb0LO0l20HQAO[223hoNi>iRdZ"
    A$ = A$ + "FL<a?QhDd==@Phi:ngmEI\784nlIn7R>W9NiiWX7JTnAST>8Qo_56`>E;5o<"
    A$ = A$ + "?kl8SkQgXWV;jIS]laQ\n@[?jOkQU=ed6FG?2ORf=DYIJ:2h;VNXhE03PX@N"
    A$ = A$ + "NJE`Ca\RB\9i7noX6SHhFQ>=W=Ca2XDXc1oioib7D_Y]fk_<d7WJFo[WW=@;"
    A$ = A$ + "eB;58_Y^]9m82n57bTk\PEi=GG;ohel`oeK8=9oS7^lkJb4j`?dd=e3oEeG]"
    A$ = A$ + "cDk3mNRc`SWHMZ4c^8ojn8U:4GR>O>Xj:kn?6LmlLP]Wf[j:VfmiGYnK`V?G"
    A$ = A$ + "O==TNj?<iCT7nfD;1[g^mfI5KUL2iSY\3:?0n\M;do4YJDV6k2N`g>00P;?7"
    A$ = A$ + "fP5>lY00>^R7CP<E:^@6P:3@5Wla00`Fj3@G03EDi[\NS=^iNe<;dBe:T^j2"
    A$ = A$ + "kCnhWlMg@NOTkJ5KdQ3_laZm:KIe;iQiP^md[oCKOXcDkendRKh]OOPffZ7m"
    A$ = A$ + "MUaZgRTMU?d=MG=LNQ6kC[oO2oFZc3gn12i9U6Q=me9GH>k1`SO\]?6?h9Zc"
    A$ = A$ + "c_AJ@Jn\2?00KOUKgk4515IlEPnVA?44JaQ`nmEB?nGkckAVeGN8h6mO=[Q\"
    A$ = A$ + "4kAACiIGZ<oL3mReOmV=o09og5?2CEkOfl32S2Nn9jd30QGM4ge@=eQYH>kM"
    A$ = A$ + "9]aonZ_JjF4dhi>V676Z6HF7d?nbYAA0U7X]UH=XB<YP\;Y9V@NdS_VdKZ\e"
    A$ = A$ + "oGNU>]><O;;bO?4D2?=X?de2cU1IlX30N[M5ho4=2<<75FM_900DQM;SkZ00"
    A$ = A$ + "h`jcnD3h0JN6[Q<0700mZZTO500h?m0<M[_V>[anPES]8gVfT`Hadolloo^W"
    A$ = A$ + "NUNjienoecoaM;NFEEGIS_gh@o?KUdQ>MWNikUmBDioO[kk^?ZYC]jcnmfOI"
    A$ = A$ + "ke[EUKmagGn8XR=NPInOAN5<LVTo9^LSLgZfBGQ5;g[C8Y[=m_LUB^MF`^N0"
    A$ = A$ + "PfHfRkDEeW1aKWKdkAm;>HE_35DM?CH1YmAmH>?lC0TXUfgiLCR>2R05KoMF"
    A$ = A$ + "iddj^H9aZ=:adckOlC7Ng?b3JDR^FK5A>da\mEMW=d0Mhe:7<YN;>Sbg0^5T"
    A$ = A$ + "a<^FjCoi@\jLSSdnYDf>PmNC0JD7?O]7ISF[I\6GcVW<^JNd0QF[E]ICMMb_"
    A$ = A$ + "4d=FD1CE;P;Y5TJG_L]oS=9fLIH^6\knPn?]DNc30h_fECoK>EP>UF`<^g20"
    A$ = A$ + "000`QJ32A3>h5707M<j1=60DI060DUah00Pmge2PSS40@mjAZmZK]g?;9LC]"
    A$ = A$ + "S@K_mbg:kVoP:\\YKg=hmEaf?ZkIV^GnjC^V?K[BoYcj;l^aa?Q`e?C;TJok"
    A$ = A$ + "<VGhaTIQWjVcM`9lOk79\hUOd9j\JaSgNlmUN]9gcEk;Rngk@\iVMN_0i=KR"
    A$ = A$ + "ljI5>mNP@SOLQXoS5KOMTj57<hd<d39=18PU?4S?KfE=f[28PP:fhRWWk>bg"
    A$ = A$ + "`>]_fe<P8F<45?dW:K[Z\6YZV5jI_BC7Ea_@D3:APmI@EeB3U2hc:Fmn8Onf"
    A$ = A$ + "UZo8b7mkMIM6iM5aWVaHn8BQbH5\7E5gG:ZmXgYo992<U]X;7ZYUmZ]LkUiL"
    A$ = A$ + "5<hRhNa7N^:FdRm5ifh6IQL9mib^G9hSSKl9mmVPh\:64ZY9NRBM@^DUO2OT"
    A$ = A$ + "00Pg:gIcOJEYhA>BK<O?1g9[Ng100cgW6T0Ro5n91@bMV0d`1hHD3e0P<0Ei"
    A$ = A$ + "4000LLd2`NiKTigcYL9bf5`[JK_oo_K^P2[UENOoo`eNhaV>GBk^\Lj9>Kcm"
    A$ = A$ + "c>I1C5demmc_nEod7_al;HDHh`7ddM[MkmZNSgGeQNdNm[f]eJa5QYNKg]kM"
    A$ = A$ + "iD[Wmnimo=jA_OQ__h`koSJkZadSA@MiVK^e]f]KGRCSTJ30<MlAoK1:Z8I["
    A$ = A$ + ";onk`ig_NmjD1R:XR2N:2T[obZOlUhj86iAE[obGn]O]:oBl7aUSdmmZDhlC"
    A$ = A$ + "oeUODm<kI5k`G`VknS?=dh?noOQP3^>Roh[E8]4TCn\Q4O4OlaG[\`7o=;kQ"
    A$ = A$ + "<87`MgG4nHX?_00XZF5;O:HYS:LQ?ElR36\hR^_YnOinEfCkWGF00hMNmDnm"
    A$ = A$ + "QSAM=Ymcf8k@8f400:NohRPo?[TUII2CL_R2h3<eCC2]<J]iQk=]2SaX0000"
    A$ = A$ + "`dO0n^35S_oiKj5?k;eFFUcGgXV?jJWoHGnIelinneV^ac<[:NPdEFh]MTY_"
    A$ = A$ + "[hg]ikRUeGi`KlfU_o`cWCJgeAW[iA>O]5??K2?\aEGTl3B9_hm3gkIo4WkB"
    A$ = A$ + "JNYajc<f5Bg>G_V6jJGd5NW=5_96b5_OI5KKON^E4A1ea=TC[cKA`0hO@iEP"
    A$ = A$ + "l0P5>0P4L0L30H1:5Cn?K^WZeBfmogNXAec\300_fk4jXR?P_TGB3`nFNO=K"
    A$ = A$ + "6BkRhSKOcna_HEcf[]_YnE\jjP]8cX`Z[h@2iVaH<6000h`m7O0nT<M?bl3h"
    A$ = A$ + "emlad`3h7iolK]BOcNdooUo\Mg]mGL_Ib3f3OfRck;JV9kIKeG??HjZY5mGi"
    A$ = A$ + "7nMlhZmagGo_?gkSodcff6Nc?hVS;b9e_Z^kQ?OUS5MF]GW[]hX:WGVY`j@7"
    A$ = A$ + "ncNR^gmVE6RgR7?V_Y?Ni5CN=d4]IjnfHIolfnmS77Ga8fk2O20HP83L6TMF"
    A$ = A$ + "YaXQ5N`2ckaPG0Ha1^]GW53M>c_X3HE0?MfIC101_d3000000009B_XD3000"
    A$ = A$ + "0TZ>DQ92hHC>21EGoC;[2=loc;GlmhU:Od\^8F?C@B^8aB5`k8i@Q\W6@6G9"
    A$ = A$ + "b;kSnm5lP5[l3B57W\ZMPYk[:eFE?o410@[@SoolX:Z;cZDM=FXSegE?1X[i"
    A$ = A$ + "4Pj`7=gW^F@f`Ycn_Y]hLEbj^9YOIMedlcoFoW<oHh[mD`Z?coolj8[W^HY>"
    A$ = A$ + "Zi5B_nN2B;0FU0=k>CYJ6J;Je7hQTZfmXomelVZG5dQ_:0KiDYclaU:6ll:5"
    A$ = A$ + "0`X<Ol7;V;<R^2Yj0\oQ;gFAiO5EE1X8Hk@`gb=>khc[>GiDm=m]`Yg_W<NZ"
    A$ = A$ + "iJcQ`jkGMkoG[kKfaog?Ri?F?fk`8`U6[oolB8\_9YIXBjod[Z\Hl4_LkWnj"
    A$ = A$ + "icaG7_9SCF6f_e2]E\F1`Rlfm]h`Qb?5Gng0EU]`Ch@Jn]l61;7ZjBeN`F9?"
    A$ = A$ + "^bd?]0?kd]B8J7f6d5?e_YHHOlW^J3S300?62W7VN9GgF_ZYbn@g[b4N5f<<"
    A$ = A$ + "f4N8\Y@\@TJfM9jNAmGFDf5>>0I>dPS?e??\inW7A\hogCVT^][^NmAOhm]I"
    A$ = A$ + "FgZRgaYOK]bS]akQh990jBlXR_ORLgjiUF]4RjX\^^Fanf;kYiOb9>cLWcWi"
    A$ = A$ + "L?TVWSNLf3mYMSn^Xf8HI8aUahQb^[ZfgmNOS5ohe_4<oa`8\V=Tm@^^MJh0"
    A$ = A$ + "0O\=ZNejUP9d<MEe\X1FP3=0ZB6PZ\X0@beWSJQ7GDFQI[?ga7h?jmnD^?3b"
    A$ = A$ + "XF;EXIi?DiCTL5M_kB3j]kRo8ije?oh1n@RlXJdgDlfJ<8fUkS?OUb:OnfOg"
    A$ = A$ + "afnWo7_GFf?Fbg^omS[iTejcOUlg[ie^elki^6N]gd5Kke^;nRKFNS?GdlD["
    A$ = A$ + "a[F[gm;aERD^Ygfo[b`CXmW@gEIS92MgG__?H5IObKEOZonfl;j_nn_MW]`="
    A$ = A$ + "oj9oka?mCGo]Wgl^;]]oL^O7Jf;YggkIOociK9m>IMn_SZYkkkcfgoCOn89k"
    A$ = A$ + "FdU_OAGMRCO7oI;S[;[\A^n=_eY_7^Rd?f9?gJaV]>H:oWCi9^@JmWiOU^g9"
    A$ = A$ + "Y^KZMhD=MgX_7fY_SVQUgjcooT<jSBmCOY8lh[MCIlmcXc]H_6Z?<9N\9nE9"
    A$ = A$ + "iYNaRUIC^N\la]W<?gFCH\RK]j3AX]H_jm^eh8fmje`^lSil>]?3R?8hJ>00"
    A$ = A$ + "%%%0"
    btemp$ = ""
    FOR i& = 1 TO LEN(A$) STEP 4: B$ = MID$(A$, i&, 4)
        IF INSTR(1, B$, "%") THEN
            FOR C% = 1 TO LEN(B$): F$ = MID$(B$, C%, 1)
                IF F$ <> "%" THEN C$ = C$ + F$
            NEXT: B$ = C$
            END IF: FOR t% = LEN(B$) TO 1 STEP -1
            B& = B& * 64 + ASC(MID$(B$, t%)) - 48
            NEXT: X$ = "": FOR t% = 1 TO LEN(B$) - 1
            X$ = X$ + CHR$(B& AND 255): B& = B& \ 256
    NEXT: btemp$ = btemp$ + X$: NEXT
    BASFILE$ = btemp$: btemp$ = ""
    OPEN "Jump-SoundBible.com-1007297584.ogg" FOR BINARY AS #1
    PUT #1, , BASFILE$
    CLOSE #1
END SUB

