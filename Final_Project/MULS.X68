*-----------------------------------------------------------
* Title      : Final Project
* Written by : MULS (Ben, Tensae, Jose, Gabriela)
* Date       : April 28, 2021
* Description: 
*-----------------------------------------------------------
MAIN:       ORG         $1000

CR:         EQU         $0D
LF:         EQU         $0A

staHex:     DC.L        $0
endHex:     DC.L        $0
*-----------------------------------------------------------
* I/O Implementation
;1. Prompt user for start and ending addresses (In hex)
;2. User inputs their values
;3. Check for errors
;        Check to see if hex is too big
;        Check to see value doesn't contain G-Z
;        Check to see if there are no commas/special chars
;        Check to see that starting loc, is before ending loc
;        Check to see if value starts at odd mem location
*-----------------------------------------------------------
            ;Show welcome to user
            LEA         Welcome,A1
            MOVE.B      #14,D0
            TRAP        #15
                   
  
startingPrompt:
            ;Ask the user for the starting hex
            LEA         userSA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ADD.W       D3,D2
            
            
            ;Clear the registers in case we had an error
            MOVE.L      #0,A1
            MOVE.L      #0,A2
            CLR.L       D3
            CLR.L       D4
            CLR.L       D5
            CLR.L       D6
           
            
            ;Input for the hex (D1 equals number of chars)
            MOVE.W      #2,D0
            TRAP        #15
            
            ;Moves A1 into A2      
            ;MOVEA.L     A1,A2
            
            ;Makes sure D7 is clear incase we're looping back after an error.
            CLR.B       D7
            
            BRA         convert  
            
endingPrompt:
            ;D7 is if we're working with the first or second promt, used in the more checks section. 
            MOVE.B       #1,D7
            
            ;Ask the user for the ending hex
            LEA         userEA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Clearing the registers so we can reuse them for the ending address
            MOVE.L      #0,A1
            MOVE.L      #0,A2
            CLR.L       D6

            ;Input for the hex (D1 equals number of chars)
            MOVE.W      #2,D0
            TRAP        #15
            
            ;Moves A1 into A2      
            ;MOVEA.L     A1,A2
            
            BRA         convert

convert:    
            ;Check to see if D1 is greater than 6, limiting the address to 6 characters (subject to change)
            CMP.B       #6, D1
            BGT         manyCharError  
            
            ;See if our counter variable is 0
            CMP.B       #0,D1
            
            ;This means that we have gone through all the characters
            BEQ         moreChecks
            
            ;Decrement the counter, this means we're about to go through another char
            SUB.B       #1,D1

            ;Let's move the byte stored at A1
            MOVE.B      (A2),D3
            
            ;If the byte is greater than or equal to hex $40, then it's a letter
            CMP.B       #$41,D3
            BGE         letter
            
            ;If the byte is less than or equal to hex $39, then it's a number
            CMP.B       #$40,D3
            BLE         number
            
letter:
            ;We do this check to see if the character is greater than or equal 'G'
            CMP.B       #$47,D3
            ;If so, then display an error and ask the user to enter startingAdd again
            BGE         charError
            
            ;Subtract the Ascii value to convert to hex
            SUB.B       #$37,D3
            ;Move the value back to our register
            MOVE.B      D3,(A2)+
            
            ;Shift D5 left to make room for next hex value
            ASL.L       #4, D6
            ;Move value to D5
            ADD.B      D3, D6
            
            BRA         convert
           

number:          
           ;We do this check to see if the character is less than or equal to '/'  
           CMP.B        #$2F,D3
           ;If so, then display an error and ask the user to enter startingAdd again
           BLE          charError     
 
           ;Check to see if the character is greater than or equal to ':'
           CMP.B        #$3A,D3
           ;If so, then display an error and ask the user to enter startingAdd again
           BGE          charError
          
           ;Subtract the Ascii value to convert to hex
           SUB.B        #$30,D3
           ;Move the value back to our register
           MOVE.B       D3,(A2)+
 
           ;Shift D5 left to make room for next hex value
           ASL.L        #4, D6
           ;Move value to D5
           ADD.B        D3, D6
            
           BRA          convert
 
          
moreChecks:
            ;Determine if we're going to moreChecks1 or moreChecks2 (if we're on starting or ending address)
            CMP.B      #1,D7
            BEQ        moreChecks2
            
            BRA        moreChecks1
 
moreChecks1:
            
            ;Copy the hex value into a temp register
            MOVE.L      D6,D4
            
            ;Placeholder to shift bits, used for seeing if the address is odd. 
            MOVE.B      #31,D5
            
            ;Shifts 31 bits, isolates last bit. 
            LSL.L       D5,D4

            ;Shifts it back 31 bit, isolating the last bit. 
            LSR.L       D5,D4

            ;If the last bit is 1, address was odd, and throw an error. 
            CMP.B       #1,D4
            BEQ         oddError   
                        
            ;Reset address registers.
            MOVE.L      #0,A2
            
            ;Copy the value to our staHex variable
            MOVE.L      D6,staHex 
            
            CLR.L       D6
            BRA         endingPrompt     
            
moreChecks2:       
            
            ;Copy the hex value into a temp register
            MOVE.L      D6,D4
            
            ;Placeholder to shift bits, used for seeing if the address is odd. 
            MOVE.B      #31,D5
            
            ;Shifts 31 bits, isolates last bit. 
            LSL.L       D5,D4

            ;Shifts it back 31 bit, isolating the last bit. 
            LSR.L       D5,D4

            ;If the last bit is 1, address was odd, and throw an error. 
            CMP.B       #1,D4
            BEQ         oddError   
                        
            ;Reset address registers.
            MOVE.L      #0,A2
            
            ;Place the value in our ending hex variable
            MOVE.L      D6,endHex 
            
            ;Make D7 a temp location to compare our starting hex
            MOVE.L      staHex,D7
         
            
            ;Compare the starting hex, with the ending hex to see if endHex is less than starting        
            CMP.L       D7,D6
            BMI         endGreater
            
            ;done, start reading memory. 
            
            ;Clear all the registers since we have the addresses stored in our variables
            CLR.L       D3
            CLR.L       D5
            CLR.L       D6
            CLR.L       D7  
            
            ;Copy the value of our starting hex to A2 (temp register)
            MOVEA.L     staHex,A2
                        
            
LOOP:   
            ;--------------------------------------------------------
            ;Check for NOP or RTS
            ;--------------------------------------------------------
            ;Move the NOP binary value for comparing
            MOVE.L      #%0100111001110001,D2
            
            ;Check and see i the instruction is NOP
            CMP.W       (A2),D2
            BEQ         printN
            
            ;Move the RTS binary value for comparing
            MOVE.L      #%0100111001110101,D2
            
            ;Check and see if the instruction is RTS
            CMP.W       (A2),D2
            BEQ         printR
            
            ;Clear the contents for reusing
            CLR.L       D2
            
            
            ;--------------------------------------------------------
            ;Check for MOVE, since it's the only word starting with 00
            ;--------------------------------------------------------            
            ;Move the value in A2 to a temp register
            MOVE.B      (A2),D2
            
            ;Shift 6 bits to the right to isolate the left-most digits
            LSR.L       #6,D2
            
            ;If the first two bits (left-most) are 00, then the instruction is MOVE
            CMP.B       #00,D2
            BLE         M00
            
            ;Reuse the register
            CLR.L       D2
            
            
            ;--------------------------------------------------------
            ;Check for other OpCodes
            ;--------------------------------------------------------
            ;Move the word into a temp register 
            MOVE.W      (A2),D2
            
            ;Since LSR can only take 0-9, we can use a data register
            MOVE.B      #12,D3
            ;Shift 12 bits to isolate the left-most digits
            LSR.L       D3,D2
                      

            
            ;MOVEM,LEA,NOT,JSR
            CMP.B       #%0100,D2
            BEQ         M0100
            
            ;BRA,BLT,BGE,BEQ
            CMP.B       #%0110,D2
            BEQ         M0110
            
            ;DIVU
            CMP.B       #%1000,D2
            BEQ         M1000
            
            ;SUB
            CMP.B       #%1001,D2
            BEQ         M1001
            
            ;MULS,AND,LSL,LSR,ASL,ASR
            CMP.B       #%1100,D2
            BEQ         M1100
            
            ;ADD
            CMP.B       #%1101,D2
            BEQ         M1101
            
            BRA         ending
            
            
            
            ;display INVALID OPCODE, and display the raw hex
            ;do this later

           
update:
            ;Check and see if we are at the ending hex
            CMP.L      endHex,A2
            BEQ        ending

            ;Update address in A2
            ADD.L      #2,A2
            
            
            BRA        LOOP

*-----------------------------------------------------------
* OpCode Implementation
;
*-----------------------------------------------------------

;MOVE
M00:
            LEA        printMOVE,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            CLR.B      D2
            CLR.B      D3
            
            
            BRA        update
          

;MOVEM,LEA,NOT,JSR
M0100:        
                 
MOVEM:
MLEA:
MNOT:
MJSR:
   

;BRA,BLT,BGE,BEQ         
M0110:
            ;
MBRA:
MBLT:
MBGE:
MBEQ:            
            
;DIVU            
M1000:

;SUB
M1001:
            LEA        printSUB,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            CLR.B      D2
            CLR.B      D3
            
            ;Copy the address values into a register
            MOVE.L     (A2),D2
            
            
            ;Shift 8 bits left
            LSL.L      #8,D2
            ;Shift 14 bits right to isolate the size (2 bits)
            LSR.L      #2,D2
            
            ;Compare to which size is being moved for the opcode
            CMP.B      #00,D2
            BEQ        PByte
            
            CMP.B      #01,D2
            BEQ        PWord
            
            CMP.B      #10,D2
            BEQ        PLong
            
            
            ;Isolate bits 5,6,7 to get the source 
            
            ;Isolate bits 11,12,13 to get the addressing mode
            
            ;Isoalte bits 14,15,16 to get the destination
            
            ;00 B, 01 W, 10 L
            
            BRA        update

;MULS,AND,LSL,LSR,ASL,ASR
M1100:

MMULS:
MAND:
MLSL:
MLSR:
MASL:
MASR:

;ADD
M1101:
            LEA        printADD,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            CLR.B      D2
            CLR.B      D3
            
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;1101 0100 00    00 0011
            ;0000 0011 0000 0000
            
            ;0000 0000 0000 0011 
            
            ;Shift 8 bits left
            LSL.L      #8,D2
            ;Shift 14 bits right to isolate the size (2 bits)
            MOVE.B     #14,D3
            LSR.W      D3,D2
            
            ;Compare to which size is being moved for the opcode
            CMP.B      #00,D2
            BEQ        PByte
            
            CMP.B      #01,D2
            BEQ        PWord
            
            CMP.B      #10,D2
            BEQ        PLong
            
            
            ;Isolate bits 5,6,7 to get the source 
            
            ;Isolate bits 11,12,13 to get the addressing mode
            
            ;Isoalte bits 14,15,16 to get the destination
            
            ;00 B, 01 W, 10 L

            
            
            BRA        update
            
            
*-----------------------------------------------------------
* Print Sizes
*-----------------------------------------------------------           
PByte:
            LEA        printSIZEB,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            RTS
PWord:
            LEA        printSIZEW,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            RTS
PLong:            
            LEA        printSIZEB,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            RTS
*-----------------------------------------------------------
* Addressing Mode Implementation
*-----------------------------------------------------------
DRD:
            ;Print D __
ARD:
            ;Print A __
ARI:
            ;Print (A __ )
IA:
            ;Print #$ ______
PI:
            ;Print (A __)+
PD:
            ;Print -(A __)
ALA:
            ;Print $-------- (8 digits)
AWA:
            ;Print $---- (4 digits)


*-----------------------------------------------------------
* Print Instructions
*-----------------------------------------------------------
printN:
            LEA        printNOP,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            BRA        update

printR:
            LEA        printRTS,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            BRA        update
;-----------------------------------------------------------
;ERROR MESSAGES
;-----------------------------------------------------------
charError:
            
            LEA         invalCh,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         startingPrompt
          
oddError:
            LEA         odd,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         startingPrompt
            
manyCharError:  
            LEA         manyChar, A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         startingPrompt
         
endGreater:
            LEA         endG,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         startingPrompt
    
;-----------------------------------------------------------
;MESSAGES
;-----------------------------------------------------------
Welcome     DC.B        'Welcome to the DASM by Group MULS',CR,LF,0
userSA      DC.B        'Please enter your starting hex address (Only uppercase letters)',CR,LF,0
userEA      DC.B        'Please enter your ending hex address (Only uppercase letters)',CR,LF,0

printNOP    DC.B        'NOP',CR,LF,0
printRTS    DC.B        'RTS',CR,LF,0
printMOVE   DC.B        'MOVE',0
printADD    DC.B        'ADD',0
printSUB    DC.B        'SUB',0

printSIZEB   DC.B        '.B ',0
printSIZEW   DC.W        '.W ',0
printSIZEL   DC.L        '.L ',0


printDRD      DC.B        'D',0
printARD      DC.B        'A',0
printARI      DC.B        '(A',0
printIA       DC.B        '#',0
printPI       DC.B        '(A',0
printPD       DC.B        '-(A',0
;printAA       DC.B        ''   /TBD


theEnd      DC.B        CR,LF,'You are now ending the program',0

;-----------------------------------------------------------
;ERRORS
;-----------------------------------------------------------
invalCh     DC.B        'ERROR: Invalid Characters used',CR,LF,0
odd         DC.B        'ERROR: Cannot start at odd memory location',CR,LF,0
manyChar    DC.B        'ERROR: Cannot have more than 6 characters in the address',CR,LF,0
endG        DC.B        'ERROR: The ending address cannot be less than the starting address',CR,LF,0

ending:
            LEA         theEnd,A1
            MOVE        #14,D0
            TRAP        #15
            
            END         MAIN 






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
