REDIM q(0) AS STRING
Split "A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,a,b,c,d,e,f,g,h,i,j," + _
    "k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,0,1,2,3,4,5,6,7,8,9,+,/", q(), ","

DIM i AS _UNSIGNED LONG
FOR i = LBOUND(q) TO UBOUND(q)
    PRINT i, q(i)
    _LIMIT 10
NEXT

SUB Split (text$, array$(), sep$)
    IF LEN(sep$) = 0 THEN EXIT SUB
    sep$ = LEFT$(sep$, 1)

    IF LEN(text$) = 0 THEN
        REDIM array$(0)
        EXIT SUB
    END IF

    REDIM array$(0 TO 1000)
    DIM item AS _UNSIGNED LONG
    DIM findSep AS _UNSIGNED LONG, curPos AS _UNSIGNED LONG

    item = -1
    DO
        findSep = INSTR(curPos + 1, text$, sep$)
        IF findSep = 0 THEN
            item = item + 1
            IF item > UBOUND(array$) THEN
                REDIM _PRESERVE array$(0 TO UBOUND(array$) + 1000)
            END IF
            array$(item) = MID$(text$, curPos + 1)
            EXIT DO
        END IF
        item = item + 1
        IF item > UBOUND(array$) THEN
            REDIM _PRESERVE array$(0 TO UBOUND(array$) + 1000)
        END IF
        array$(item) = MID$(text$, curPos + 1, findSep - curPos - 1)
        curPos = findSep
    LOOP
    REDIM _PRESERVE array$(0 TO item)
END SUB

