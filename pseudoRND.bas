CONST maxRND = 1000000
DIM SHARED rndTable(1 TO maxRND) AS SINGLE
DIM SHARED rndSeed AS LONG, rndIndex AS LONG
RANDOMIZE 8
DIM i&
FOR i& = 1 TO maxRND
    rndTable(i&) = RND
NEXT

SUB setRand (seed&)
    IF seed& > UBOUND(rndtable) OR seed& < 1 THEN
        rndIndex = 1
    ELSE
        rndIndex = seed&
    END IF
END SUB

FUNCTION getRND
    rndIndex = rndIndex + 1
    IF rndIndex > UBOUND(rndtable) THEN rndIndex = 1
    getRND = rndTable(rndIndex)
END FUNCTION

