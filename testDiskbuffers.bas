TYPE diskBuffers
    filename AS STRING
    state AS _BYTE
END TYPE
DIM SHARED diskBufferControl(1 TO 255) AS diskBuffers
DIM SHARED diskBuffer(1 TO 255) AS STRING

OpenBuffer "testing.txt", "OUTPUT", 1
PrintToBuffer 1, "Hello, world!", 0
CloseBuffer 1

OpenBuffer "testing2.txt", "APPEND", 1
PrintToBuffer 1, "If you're happy and you know it, ", -1
CloseBuffer 1

OpenBuffer "testing2.txt", "APPEND", 2
PrintToBuffer 2, "clap your hands.", 0
CloseBuffer 2

CommitBuffersToDisk

SUB OpenBuffer (filename$, mode$, handle)
    IF diskBufferControl(handle).state = -1 THEN ERROR 55: EXIT SUB

    'locate existing named buffer
    FOR i = 1 TO UBOUND(diskBufferControl)
        IF diskBufferControl(i).filename = filename$ THEN
            IF diskBufferControl(i).state THEN ERROR 55: EXIT SUB
            'found existing buffer - reuse it.
            tempBuffer$ = diskBuffer(i)
            diskBufferControl(i).filename = ""
            diskBuffer(i) = ""
            EXIT FOR
        END IF
    NEXT

    'commit any pre-existing data if this handle is being reused
    CommitBufferToDisk handle

    SELECT CASE UCASE$(mode$)
        CASE "OUTPUT"
            diskBuffer(handle) = ""
        CASE "APPEND"
            diskBuffer(handle) = tempBuffer$
    END SELECT
    diskBufferControl(handle).filename = filename$
    diskBufferControl(handle).state = -1 'open
END SUB

SUB CloseBuffer (handle)
    diskBufferControl(handle).state = 0
END SUB

SUB PrintToBuffer (handle, text$, retainCursor AS _BYTE)
    'IF diskBuffer(handle).state = 0 THEN ERROR 5: EXIT SUB
    IF NOT retainCursor THEN lf$ = CHR$(10)
    diskBuffer(handle) = diskBuffer(handle) + text$ + lf$
END SUB

FUNCTION FreeBuffer%
    FOR i = 1 TO UBOUND(diskBufferControl)
        IF diskBufferControl(i).state = 0 THEN FreeBuffer% = i: EXIT FUNCTION
    NEXT
END FUNCTION

SUB CommitBufferToDisk (handle)
    IF LEN(diskBufferControl(handle).filename) THEN
        CloseBuffer handle
        IF _FILEEXISTS(diskBufferControl(handle).filename) THEN KILL diskBufferControl(handle).filename
        fh = FREEFILE
        OPEN diskBufferControl(handle).filename FOR BINARY AS #fh
        tempbuffer$ = diskBuffer(handle)
        PUT #fh, , tempbuffer$
        CLOSE #fh
    END IF
END SUB

SUB CommitBuffersToDisk
    FOR i = 1 TO UBOUND(diskBufferControl)
        CommitBufferToDisk i
    NEXT
END SUB

SUB ResetBuffers
    FOR i = 1 TO UBOUND(diskBufferControl)
        diskBufferControl(i).filename = ""
        diskBuffer(i) = ""
        diskBufferControl(i).state = 0
    NEXT
END SUB

