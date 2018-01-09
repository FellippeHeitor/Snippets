DIM SHARED display&, canvas&

display& = _NEWIMAGE(800, 600, 32)
canvas& = _NEWIMAGE(100, 50, 32)
SCREEN display&
_SOURCE canvas&

CONST true = -1, false = NOT true

TYPE new_Particle
    x AS SINGLE
    y AS SINGLE
    xv AS SINGLE
    xacc AS SINGLE
    yv AS SINGLE
    yacc AS SINGLE
    c AS _UNSIGNED LONG
    alive AS _BYTE
END TYPE

CONST g = .01
CONST airResistance = .01

DIM i AS LONG
DIM SHARED totalParticles AS LONG
REDIM SHARED particle(0) AS new_Particle
DO
    WHILE _MOUSEINPUT: WEND

    IF _MOUSEBUTTON(1) THEN
        addParticle map(_MOUSEX, 0, _WIDTH - 1, 0, _WIDTH(canvas&)), map(_MOUSEY, 0, _HEIGHT - 1, 0, _HEIGHT(canvas&))
    END IF

    showParticles
    moveParticles
    _PUTIMAGE , canvas&
    _LIMIT 60
LOOP

SUB addParticle (x AS INTEGER, y AS INTEGER)
    DIM i AS LONG

    FOR i = 1 TO UBOUND(particle)
        IF particle(i).y >= _HEIGHT(canvas&) THEN EXIT FOR
    NEXT

    IF i > UBOUND(particle) THEN
        totalParticles = totalParticles + 1
        IF totalParticles > UBOUND(particle) THEN
            REDIM _PRESERVE particle(UBOUND(particle) + 100) AS new_Particle
        END IF
        i = totalParticles
    END IF
    particle(i).x = x
    particle(i).y = y
    particle(i).yv = 0
    particle(i).yacc = g
    particle(i).c = _RGB32(255, 255, 255)
    particle(i).alive = true
END SUB

SUB showParticles
    DIM i AS LONG
    _DEST canvas&
    CLS
    FOR i = 1 TO totalParticles
        PSET (particle(i).x, particle(i).y), particle(i).c
    NEXT

    '_PRINTSTRING (0, 0), STR$(totalParticles) + STR$(UBOUND(particle))
    _DEST display&
END SUB

SUB moveParticles
    DIM i AS LONG, j AS LONG
    FOR i = 1 TO totalParticles
        IF particle(i).alive THEN
            particle(i).yacc = particle(i).yacc + g
            particle(i).yv = particle(i).yv + particle(i).yacc
            particle(i).y = particle(i).y + particle(i).yv
            IF particle(i).y > _HEIGHT(canvas&) - 1 THEN
                FOR j = _HEIGHT(canvas&) - 1 TO 0 STEP -1
                    IF POINT(particle(i).x, j) = _RGB32(0, 0, 0) THEN
                        particle(i).y = j
                        particle(i).alive = false
                        particle(i).yv = 0
                        particle(i).yacc = 0
                        EXIT FOR
                    END IF
                NEXT
            END IF
        ELSE
            IF POINT(particle(i).x, particle(i).y + 1) = _RGB32(0, 0, 0) THEN particle(i).alive = true
        END IF
    NEXT
    _DISPLAY
END SUB

FUNCTION map! (value!, minRange!, maxRange!, newMinRange!, newMaxRange!)
    map! = ((value! - minRange!) / (maxRange! - minRange!)) * (newMaxRange! - newMinRange!) + newMinRange!
END FUNCTION

