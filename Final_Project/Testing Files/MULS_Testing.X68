*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $7000
START:                  ; first instruction of program

    BCC    BRANCH1    
    BRA    BRANCH2
    BRA    $1020
    BEQ    BRANCH3
    BLT    BRANCH4
    BGE    BRANCH5

    ;Testing NOP
    NOP
    NOP
    NOP
    
BRANCH1:
    MOVE.B  D1,D3   
    MOVE.B  D5,(A4)
    MOVE.B  D6,-(A0)
    MOVE.B  D1,(A4)+
    MOVE.B  D2,$4567
    MOVE.B  D6,$1234567    
    MOVE.B  (A4),D3
    MOVE.B  (A5),(A6)
    MOVE.B  (A7),-(A0)
    MOVE.B  (A1),(A2)+
    MOVE.B  (A3),$4567
    MOVE.B  (A0),$1234567
    MOVE.B  -(A4),D3
    MOVE.B  -(A5),(A6)
    MOVE.B  -(A7),-(A0)
    MOVE.B  -(A1),(A2)+
    MOVE.B  -(A3),$4567
    MOVE.B  -(A0),$1234567
    MOVE.B  (A4)+,D3
    MOVE.B  (A5)+,(A6)
    MOVE.B  (A7)+,-(A0)
    MOVE.B  (A1)+,(A2)+
    MOVE.B  (A3)+,$4567
    MOVE.B  (A0)+,$1234567
    MOVE.B  $123,D3
    MOVE.B  $123,(A6)
    MOVE.B  $123,-(A0)
    MOVE.B  $123,(A2)+
    MOVE.B  $123,$4567
    MOVE.B  $123,$1234567
    MOVE.B  $1234567,D3
    MOVE.B  $1234567,(A6)
    MOVE.B  $1234567,-(A0)
    MOVE.B  $1234567,(A2)+
    MOVE.B  $1234567,$4567
    MOVE.B  $1234567,$1234567
    
    MOVE.W  A4,D3
    MOVE.W  A5,(A6)
    MOVE.W  A7,-(A0)
    MOVE.W  A1,(A2)+
    MOVE.W  A3,$4567
    MOVE.W  A0,$1234567
    MOVE.W  D4,D3
    MOVE.W  D5,(A6)
    MOVE.W  D7,-(A0)
    MOVE.W  D1,(A2)+
    MOVE.W  D3,$4567
    MOVE.W  D0,$1234567    
    MOVE.W  (A4),D3
    MOVE.W  (A5),(A6)
    MOVE.W  (A7),-(A0)
    MOVE.W  (A1),(A2)+
    MOVE.W  (A3),$4567
    MOVE.W  (A0),$1234567
    MOVE.W  -(A4),D3
    MOVE.W  -(A5),(A6)
    MOVE.W  -(A7),-(A0)
    MOVE.W  -(A1),(A2)+
    MOVE.W  -(A3),$4567
    MOVE.W  -(A0),$1234567
    MOVE.W  (A4)+,D3
    MOVE.W  (A5)+,(A6)
    MOVE.W  (A7)+,-(A0)
    MOVE.W  (A1)+,(A2)+
    MOVE.W  (A3)+,$4567
    MOVE.W  (A0)+,$1234567
    MOVE.W  $123,D3
    MOVE.W  $123,(A6)
    MOVE.W  $123,-(A0)
    MOVE.W  $123,(A2)+
    MOVE.W  $123,$4567
    MOVE.W  $123,$1234567   
    MOVE.W  $1234567,D3
    MOVE.W  $1234567,(A6)
    MOVE.W  $1234567,-(A0)
    MOVE.W  $1234567,(A2)+
    MOVE.W  $1234567,$4567
    MOVE.W  $1234567,$1234567
    
    MOVE.L  A4,D3
    MOVE.L  A5,(A6)
    MOVE.L  A7,-(A0)
    MOVE.L  A1,(A2)+
    MOVE.L  A3,$4567
    MOVE.L  A0,$1234567
    MOVE.L  D4,D3
    MOVE.L  D5,(A6)
    MOVE.L  D7,-(A0)
    MOVE.L  D1,(A2)+
    MOVE.L  D3,$4567
    MOVE.L  D0,$1234567  
    MOVE.L  (A4),D3
    MOVE.L  (A5),(A6)
    MOVE.L  (A7),-(A0)
    MOVE.L  (A1),(A2)+
    MOVE.L  (A3),$4567
    MOVE.L  (A0),$1234567
    MOVE.L  -(A4),D3
    MOVE.L  -(A5),(A6)
    MOVE.L  -(A7),-(A0)
    MOVE.L  -(A1),(A2)+
    MOVE.L  -(A3),$4567
    MOVE.L  -(A0),$1234567
    MOVE.L  (A4)+,D3
    MOVE.L  (A5)+,(A6)
    MOVE.L  (A7)+,-(A0)
    MOVE.L  (A1)+,(A2)+
    MOVE.L  (A3)+,$4567
    MOVE.L  (A0)+,$1234567
    MOVE.L  $123,D3
    MOVE.L  $123,(A6)
    MOVE.L  $123,-(A0)
    MOVE.L  $123,(A2)+
    MOVE.L  $123,$4567
    MOVE.L  $123,$1234567    
    MOVE.L  $1234567,D3
    MOVE.L  $1234567,(A6)
    MOVE.L  $1234567,-(A0)
    MOVE.L  $1234567,(A2)+
    MOVE.L  $1234567,$4567
    MOVE.L  $1234567,$1234567
    
    ;MOVEM
    MOVEM.L D0-D3/D5/A2-A7, (A3)
    MOVEM   D0-D3/D5/A2-A7, -(A3)
    MOVEM   D0-D3/D5/A2-A7, $1234
    MOVEM   D0-D3/D5/A2-A7, $12345678
            
    MOVEM   (A3), D4
    MOVEM   (A3)+, D4
    MOVEM   $1234, D4
    MOVEM   $12345678, D4

    
BRANCH2:    
    ;Testing Add (Some might come as ADDI)
    ADD.B    D2,D1   
    ADD.B    D3,D4
    ADD.B    (A5),D6
    ADD.B    -(A7),D0
    ADD.B    (A1)+,D2
    ADD.B    $3456,D7
    ADD.B    $1234567,D0

    ADD.W    D2,D1
    ADD.W    D3,D4
    ADD.W    (A5),D6
    ADD.W    -(A7),D0
    ADD.W    (A1)+,D2
    ADD.W    $3456,D7
    ADD.W    $1234567,D0
    
    ADD.L    D2,D1
    ADD.L    D3,D4
    ADD.L    (A5),D6
    ADD.L    -(A7),D0
    ADD.L    (A1)+,D2
    ADD.L    $3456,D7
    ADD.L    $1234567,D0

BRANCH3:    
    ;Testing SUB
    SUB.B   D2,D1
    SUB.B   D3,D4
    SUB.B   (A5),D6
    SUB.B   -(A7),D0
    SUB.B   (A1)+,D2
    SUB.B   $3456,D7
    SUB.B   $1234567,D0

    SUB.W   D2,D1
    SUB.W   D3,D4
    SUB.W   (A5),D6
    SUB.W   -(A7),D0
    SUB.W   (A1)+,D2
    SUB.W   $3456,D7
    SUB.W   $1234567,D0

    SUB.L   D2,D1
    SUB.L   D3,D4
    SUB.L   (A5),D6
    SUB.L   -(A7),D0
    SUB.L   (A1)+,D2
    SUB.L   $3456,D7
    SUB.L   $1234567,D0
    
    ;Testing MULS
    MULS    D2,D1   
    MULS    D3,D4
    MULS    (A5),D6
    MULS    -(A7),D0
    MULS    (A1)+,D2
    MULS    $3456,D7
    MULS    $01234567,D0
    MULS    #123,D4
    MULS    #$123,D4
    MULS    #12345,D0
    MULS    #$4567,D0
    
    ;Testing DIVU
    DIVU    D2,D1   
    DIVU    D3,D4
    DIVU    (A5),D6
    DIVU    -(A7),D0
    DIVU    (A1)+,D2
    DIVU    $3456,D7
    DIVU    $01234567,D0
    DIVU    #123,D4
    DIVU    #$123,D4
    DIVU    #12345,D0
    DIVU    #$4567,D0
    
    ;Testing LEA
    LEA     (A4),A0   
    LEA     $2468,A4
    LEA     $1234567,A3
    
    ;Testing AND
    AND.B    D2,D1   *TESTING ANDS
    AND.B    D3,D4
    AND.B    (A5),D6
    AND.B    -(A7),D0
    AND.B    (A1)+,D2
    AND.B    $3456,D7
    AND.B    $01234567,D0
    AND.B    #123,D4
    AND.B    #$12,D4
    AND.B    #123,D0
    AND.B    #$87,D0
    
    AND.W    D2,D1
    AND.W    D3,D4
    AND.W    (A5),D6
    AND.W    -(A7),D0
    AND.W    (A1)+,D2
    AND.W    $3456,D7
    AND.W    $01234567,D0
    AND.W    #123,D4
    AND.W    #$123,D4
    AND.W    #12345,D0
    AND.W    #$4567,D0

    AND.L    D2,D1
    AND.L    D3,D4
    AND.L    (A5),D6
    AND.L    -(A7),D0
    AND.L    (A1)+,D2
    AND.L    $3456,D7
    AND.L    $01234567,D0
    AND.L    #123,D4
    AND.L    #$123,D4
    AND.L    #12345,D0
    AND.L    #$4567,D0
    
    ;Testing NOT
    NOT.W   D1  
    NOT.W   (A2)
    NOT.W   -(A3)
    NOT.W   (A4)+
    NOT.W   $4567
    NOT.W   $1234567

    NOT.L   D1
    NOT.L   (A2)
    NOT.L   -(A3)
    NOT.L   (A4)+
    NOT.L   $4567
    NOT.L   $01234567

BRANCH4:
    ;Testing LSL
    LSL     $00002000   
    LSL     $2000
    LSL     (A2)
    LSL     (A2)+
    LSL     -(A2)
  
    LSL.B   #1,D0
    LSL.B   D0,D1
    LSL.B   #1,D0
    LSL.B   D0,D1

    LSL.W   #1,D0
    LSL.W   D0,D1
    LSL.W   #1,D0
    LSL.W   D0,D1

    LSL.L   #1,D0
    LSL.L   D0,D1
    LSL.L   #1,D0
    LSL.L   D0,D1
    
    ;Testing LSR
    LSR     $00002000   
    LSR     $2000
    LSR     (A2)
    LSR     (A2)+
    LSR     -(A2)
  
    LSR.B   #1,D0
    LSR.B   D0,D1
    LSR.B   #1,D0
    LSR.B   D0,D1

    LSR.W   #1,D0
    LSR.W   D0,D1
    LSR.W   #1,D0
    LSR.W   D0,D1

    LSR.L   #1,D0
    LSR.L   D0,D1
    LSR.L   #1,D0
    LSR.L   D0,D1
    
    ;Testing ASL
    ASL     $00002000   
    ASL     $2000
    ASL     (A2)
    ASL     (A2)+
    ASL     -(A2)    
    
    ASL.B   #1,D0
    ASL.B   D0,D1
    ASL.B   #1,D0
    ASL.B   D0,D1

    ASL.W   #1,D0
    ASL.W   D0,D1
    ASL.W   #1,D0
    ASL.W   D0,D1

    ASL.L   #1,D0
    ASL.L   D0,D1
    ASL.L   #1,D0
    ASL.L   D0,D1
    
    ;Testing ASR
    ASR     $00002000   
    ASR     $2000
    ASR     (A2)
    ASR     (A2)+
    ASR     -(A2)    
    
    ASR.B   #1,D0
    ASR.B   D0,D1
    ASR.B   #1,D0
    ASR.B   D0,D1

    ASR.W   #1,D0
    ASR.W   D0,D1
    ASR.W   #1,D0
    ASR.W   D0,D1

    ASR.L   #1,D0
    ASR.L   D0,D1
    ASR.L   #1,D0
    ASR.L   D0,D1

    ;Testing BLT
    ;Testing BGE
    ;Testing BEQ
    ;Testing Bcc
    
BRANCH5:    
    ;Testing JSR
    JSR   BRANCH1   
    JSR   BRANCH2
    JSR   BRANCH3
    
    ;Testing RTS
    RTS  
    RTS
    RTS
    
    ;Testing BRA
    
    SIMHALT  

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
