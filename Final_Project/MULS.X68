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
                   
            ;===TESTING===
            LEA (A3),A4
            NOT.B    D0
            ASL.L      D2, D1  
            LSR.W      D1, D0
            ASR        (A1)
            LSL.B      #8, D2
            
startingPrompt:
            ;Ask the user for the starting hex3
            LEA         userSA,A1
            MOVE.B      #14,D0
            TRAP        #15        
            
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
            BEQ         printMRTS
            
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
            
            ;Passing in parameters for isolating the left most hand 4 bits of D2 using getBits
            MOVE.B        #12,D3            ;Start bit index = 12
            MOVE.B        #4,D4             ;Number of bits needed = 4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR           getBits            

            
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
            
            ;MULS,AND
            CMP.B       #%1100,D2
            BEQ         M1100
            
            ;LSL,LSR,ASL,ASR
            CMP.B       #%1110,D2
            BEQ         M1110
            
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
            
            
getBits:
            ;GETS ___ MANY BITS STARTING FROM __ START BIT INDEX
            ;PARAMETERS:
            ;D2 = the value the bits are extracted from & saved back in
            ;D3 = the start bit index (starting from 0)
            ;D4 = the number of bits we want to extract
            
            ;Calculate left shift
            MOVE.W      #16,D5
            
            ADD.W       D3,D4             ; start bit index + number of bits needed = X 
            SUB.W       D4,D5             ; 16 - X = leftShift
            
            LSL.W       D5,D2
            
            
            ;Calculate right shift
            ADD.W       D3,D5             ; start bit + leftShift = X
            LSR.W       D5,D2
            
            CLR.L       D3
            CLR.L       D4
            CLR.L       D5   
            RTS

*-----------------------------------------------------------
* OpCode Implementation
*-----------------------------------------------------------


*-----------------------------------------------------------
* MOVE INSTRUCTION
*-----------------------------------------------------------
M00:
            LEA        printMOVE,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            CLR.B      D2
            CLR.B      D3
            
            ;======Isolate Size (S) Bits=======
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating size bits 12,13
            MOVE.B      #13,D3             
            MOVE.B      #2,D4             
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Jumps to printSizeSubroutine and returns after size has been printed
            BSR         printSizeSubroutine
            
            ;Clear the register so we can reuse it
            CLR.L       D2
            
            MOVE.B      (A2),D2

            
            ;Get bits 11-6 for the source
            ;First we must figure out the register that is being used
            ;Then find the addressing mode
            
            ;Get bits 0-15 for the destination
            ;This uses the same procedure from previous opcodes
            ;First find the addressing mode
            ;Then find the register that is being used
            
            BRA        update
          

*-----------------------------------------------------------
* MOVEM,LEA,NOT,JSR INSTRUCTIONS
*-----------------------------------------------------------
M0100:      
            CLR.L       D2
            CLR.L       D3
            
            ;--------------------------------------------------------
            ;Check for LEA
            ;--------------------------------------------------------
            ;Copy the address values into a register to check for LEA
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bits 6,7,8
            MOVE.B      #6,D3             ;Start bit index = 6
            MOVE.B      #3,D4             ;Number of bits needed = 3
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits

            CMP.B       #%111,D2
            BEQ         MLEA

            ;--------------------------------------------------------
            ;Check for NOT
            ;--------------------------------------------------------
            ;Clear D2 and recopy it to check for NOT
            CLR.L       D2
            MOVE.W      (A2),D2
            
            ;Pass in parameters for isolating bits 8,9,10,11
            MOVE.B      #8,D3
            MOVE.B      #4,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            CMP.B       #%0110,D2
            BEQ         MNOT      
            
            ;--------------------------------------------------------
            ;Check for JSR
            ;--------------------------------------------------------
            ;Clear D2 and recopy it to check for JSR
            CLR.L       D2
            MOVE.W     (A2),D2
            
            ;Pass in parameters for isolating bits 6-11
            MOVE.B      #6,D3
            MOVE.B      #6,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            CMP.B       #%111010,D2
            BEQ         MJSR
            
            ;--------------------------------------------------------
            ;Check for MOVEM
            ;--------------------------------------------------------
            ;Clear D2 and recopy it to check for MOVEM
            CLR.L       D2
            MOVE.W     (A2),D2
            
            ;Pass in parameters for isolating bit 9
            MOVE.B      #9,D3
            MOVE.B      #1,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            CMP.B       #%0,D2
            BEQ         MOVEM
            
       
MOVEM:

MLEA:
            LEA         printLEA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;*SOURCE*
            ;Jumps to helper subroutine to isolates and return the address mode & register stored in bits 0 - 5
            ;D6 will contain mode & D7 will contain the register after this instruction
            BSR         isolateAddressBit0to5
            
            ;*Print source address*
            BSR         addressModeSR
            
            ;Print comma after source address
            LEA         printComma,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;*DESTINATION*
            ;Jumps to helper subroutine to isolates and return the register stored in bits 9 - 11
            ;D7 will contain the register after this instruction
            BSR         isolateRegisterBit9to11
            
            ;Save #%001 into D6 to specify address register mode
            MOVE.B      #1,D6
            
            
            ;*Print destination address*
            BSR         addressModeSR

            BRA        update

MNOT:
            LEA        printNOT,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            CLR.L      D2
            ;Move the address into the register to check for size
            MOVE.W     (A2),D2
            
            ;Pass in parameters for isolating bits 6,7
            MOVE.B     #6,D3
            MOVE.B     #2,D4
            
            ;Jump to getbits and return with isolated bits
            BSR        getbits          
            
            ;Jumps to printSizeSubroutine and returns after size has been printed
            BSR        printSizeSubroutine
            
            ;*SOURCE*
            ;Jumps to helper subroutine to isolates and return the address mode & register stored in bits 0 - 5
            ;D6 will contain mode & D7 will contain the register after this instruction
            BSR        isolateAddressBit0to5
            
            ;*Print source address*
            BSR        addressModeSR
            
            BRA        update 

MJSR:
            LEA        printJSR,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            ;*SOURCE*
            ;Jumps to helper subroutine to isolates and return the address mode & register stored in bits 0 - 5
            ;D6 will contain mode & D7 will contain the register after this instruction
            BSR        isolateAddressBit0to5
            
            ;*Print source address*
            BSR        addressModeSR
            
            BRA        update 
            

*-----------------------------------------------------------
* BRA,BLT,BGE,BEQ INSTRUCTIONS
*-----------------------------------------------------------       
M0110:
            ;
MBRA:
MBLT:
MBGE:
MBEQ:            
            

*-----------------------------------------------------------
* DIVU INSTRUCTION
*-----------------------------------------------------------           
M1000:
            
            CLR.L       D2
            CLR.L       D3
            
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bits 6,7,8
            MOVE.B      #6,D3             ;Start bit index = 6
            MOVE.B      #3,D4             ;Number of bits needed = 3
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            ;If bits 6,7,8 are #%011, then it's DIVU. Otherwise, branch to error message
            CMP.L       #%011,D2
            BEQ         continueDIVU
            
            ;************TO DO: BRANCH TO ERROR MESSAGE IF NOT DIVU**************

continueDIVU:

            LEA         printDIVU,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         dnDest
            
            
*-----------------------------------------------------------
* SUB INSTRUCTION
*-----------------------------------------------------------  
M1001:
            LEA        printSUB,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            CLR.B      D2
            CLR.B      D3
            
            ;======Isolate Size (S) Bits=======
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating size bits
            MOVE.B      #6,D3             ;Start bit index = 6
            MOVE.B      #2,D4             ;Number of bits needed = 2
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Jumps to printSizeSubroutine and returns after size has been printed
            BSR         printSizeSubroutine
            
       
            ;======Isolate direction (D) Bit=======
            ; 0 = data register is destination | 1 = Dn is source
            CLR.L       D2
            
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating direction bit
            MOVE.B      #8,D3             ;Start bit index = 8
            MOVE.B      #1,D4             ;Number of bits needed = 1
            
            ;Jumps to getBits and returns with isolated bit in D2
            BSR         getBits
            
            ;Uses direction bit to see if Dn is the destination. Important because it determines the order in which we isolate and print the addressing bits.
            CMP.B       #0,D2
            BEQ         dnDest
            BRA         dnSource


*-----------------------------------------------------------
* MULS,AND INSTRUCTIONS
*-----------------------------------------------------------  
M1100:      
            CLR.L       D2
            CLR.L       D3
            
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bits 6 and 7
            MOVE.B      #6,D3             ;Start bit index = 6
            MOVE.B      #2,D4             ;Number of bits needed = 2
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;If bits 6 & 7 are not #%11 then the opcode is MAND. If they are, then check 8th bit to determine if its MULS
            CMP.B       #%11,D2
            BEQ         mulsCheck
            BRA         MAND
            
mulsCheck:
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bit 8
            MOVE.B      #8,D3             ;Start bit index = 8
            MOVE.B      #1,D4             ;Number of bits needed = 1
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits 
            
            ;If 8th bit is 1 then branch to MULS. Otherwise, print error
            CMP.B       #1,D2
            BEQ         MMULS
            
            ;************TO DO: BRANCH TO ERROR MESSAGE IF NOT MULS**************

            
            
            
MMULS:
            LEA         printMULS,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         dnDest 


MAND:
            LEA        printAND,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            ;D2 already contains the size bits for AND (bits 6,7) so no need for isolating again
            ;Jumps to printSizeSubroutine and returns after size has been printed
            BSR         printSizeSubroutine
            
            ;======Isolate direction (D) Bit=======
            ; 0 = data register is destination | 1 = Dn is source
            CLR.L       D2
            
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating direction bit
            MOVE.B      #8,D3           ;Start bit index = 8
            MOVE.B      #1,D4           ;Number of bits needed = 1

            ;Jumps to getBits and returns with isolated bit in D2
            BSR         getBits
            
            ;Uses direction bit to see if Dn is the destination. Important because it determines the order in which we isolate and print the addressing bits.
            CMP.B       #0,D2
            BEQ         dnDest
            BRA         dnSource
            
            
            BRA         update          ;Unnecessary with current implementation. dnDest & dnSource will call it instead
   
   
*-----------------------------------------------------------
* LSL,LSR,ASL,ASR INSTRUCTIONS
*-----------------------------------------------------------  
M1110: 
            CLR.L       D2
            CLR.L       D3
            
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bits 6-7
            MOVE.B      #6,D3             ;Start bit index = 6
            MOVE.B      #2,D4             ;Number of bits needed = 2
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Check if Memory Shift
            CMP.B       #%11,D2
            BEQ         MemShift
            
            ;If not Memory Shift, is a Register Shift
            
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bit 3
            MOVE.B      #3,D3             ;Start bit index = 3
            MOVE.B      #1,D4             ;Number of bits needed = 1
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Checks if ASd
            CMP.B       #%0,D2
            BEQ         RegAS
            
            ;Checks if LSd
            CMP.B       #%1,D2
            BEQ         RegLS
RegShift      
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bits 6-7
            MOVE.B      #6,D3             ;Start bit index = 6
            MOVE.B      #2,D4             ;Number of bits needed = 2
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Print Size
            BSR         printSizeSubroutine
            
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bit 5
            MOVE.B      #5,D3             ;Start bit index = 5
            MOVE.B      #1,D4             ;Number of bits needed = 1
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Checks if shift count is immediate
            CMP.B       #%0,D2
            BEQ         ImmediateCount
            
            ;Jumps to helper subroutine to isolates and return the register stored in bits 9 - 11
            ;D7 will contain the register after this instruction
            BSR         isolateRegisterBit9to11
            
            ;Save #%000 into D6 to specify data register mode
            MOVE.B      #0,D6
            
            ;*Print Shift Count address*
            BSR         addressModeSR

            BSR         RegShift2

RegShift2   ;Print comma after shift count
            LEA         printComma,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;*Data Register to be Shifted*
            CLR.L       D2
            
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating bits 0-2
            MOVE.B      #0,D3             ;Start bit index = 0
            MOVE.B      #3,D4             ;Number of bits needed = 3
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            ;Save Xn register bit into ***D7*** for later use in addressModeSR
            MOVE.B      D2,D7
            
            ;Save #%000 into D6 to specify data register mode
            MOVE.B      #0,D6
            
            ;*Prints data register to be shifted*
            BSR         addressModeSR

            BRA         update
            
ImmediateCount
            ;Print #$
            LEA        printIA,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bits 9-11
            MOVE.B      #9,D3             ;Start bit index = 9
            MOVE.B      #3,D4             ;Number of bits needed = 3
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Check if shift count is 8
            CMP.B       #%000,D2
            BEQ         ShiftEight
            
            MOVE.B      D2, D1
            BSR         ImmediateCount2
           
ImmediateCount2
            ;Print shift count
            MOVE.B      #3,D0
            TRAP        #15
            BSR         RegShift2
 
ShiftEight  ;Move 8 into D1    
            MOVE.B      #8, D1
            BSR         ImmediateCount2
                                   
MemShift
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bit 9
            MOVE.B      #9,D3             ;Start bit index = 9
            MOVE.B      #1,D4             ;Number of bits needed = 1
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Checks if ASd
            CMP.B       #%0,D2
            BEQ         MemAS
            
            ;Checks if LSd
            CMP.B       #%1,D2
            BEQ         MemLS

MemShift2   
            ;Print Space
            LEA        printSpace,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            ;*Memory Address*
            ;Jumps to helper subroutine to isolates and return the address mode & register stored in bits 0 - 5
            ;D6 will contain mode & D7 will contain the register after this instruction
            BSR         isolateAddressBit0to5
            
            ;*Print source address*
            BSR         addressModeSR
            
            BRA         update
            
MemAS       ;Print AS
            BSR         MAS      
            BSR         MemDirectionSubroutine                

            
MemLS       ;Print LS
            BSR         MLS      
            BSR         MemDirectionSubroutine
            
RegAS       ;Print AS
            BSR         MAS      
            BSR         RegDirectionSubroutine                

            
RegLS       ;Print LS
            BSR         MLS      
            BSR         RegDirectionSubroutine

MLS:
            LEA        printMLS,A1
            MOVE.B     #14,D0
            TRAP       #15
            RTS
MAS:
            LEA        printMAS,A1
            MOVE.B     #14,D0
            TRAP       #15
            RTS

MemDirectionSubroutine
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bit 8
            MOVE.B      #8,D3             ;Start bit index = 8
            MOVE.B      #1,D4             ;Number of bits needed = 1
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Checks if Right
            CMP.B       #%0,D2
            BEQ         MR
            
            ;Checks if Left
            CMP.B       #%1,D2
            BEQ         ML
                        
MR          LEA        printR,A1
            MOVE.B     #14,D0
            TRAP       #15
            BSR        MemShift2

ML          LEA        printL,A1
            MOVE.B     #14,D0
            TRAP       #15
            BSR        MemShift2
            
RegDirectionSubroutine
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating bit 8
            MOVE.B      #8,D3             ;Start bit index = 8
            MOVE.B      #1,D4             ;Number of bits needed = 1
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Checks if Right
            CMP.B       #%0,D2
            BEQ         RR
            
            ;Checks if Left
            CMP.B       #%1,D2
            BEQ         RL
                        
RR          LEA        printR,A1
            MOVE.B     #14,D0
            TRAP       #15
            BSR        RegShift

RL          LEA        printL,A1
            MOVE.B     #14,D0
            TRAP       #15
            BSR        RegShift
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------




;ADD
M1101:
            LEA        printADD,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            CLR.B      D2
            CLR.B      D3
            
            ;======Isolate Size (S) Bits=======
            ;Copy the address values into a register
            MOVE.W     (A2),D2
            
            ;Passing in parameters for isolating size bits
            MOVE.B      #6,D3             ;Start bit index = 6
            MOVE.B      #2,D4             ;Number of bits needed = 2
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Jumps to printSizeSubroutine and returns after size has been printed
            BSR         printSizeSubroutine
       
            ;======Isolate direction (D) Bit=======
            ; 0 = data register is destination | 1 = Dn is source
            CLR.L       D2
            
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating direction bit
            MOVE.B      #8,D3             ;Start bit index = 8
            MOVE.B      #1,D4             ;Number of bits needed = 1
            
            ;Jumps to getBits and returns with isolated bit in D2
            BSR         getBits
            
            ;Uses direction bit to see if Dn is the destination. Important because it determines the order in which we isolate and print the addressing bits.
            CMP.B       #0,D2
            BEQ         dnDest
            BRA         dnSource
            

*-----------------------------------------------------------------
* dnDest, dnSource, & other subroutines for isolating address bits
*-----------------------------------------------------------------
;* dnDest,dnSource *
;For: MULS,AND,ADD,SUB,DIVU
;Used by instructions that require Dn as one of their addressing modes.
;dnDest isolates the addressing bits with Dn being the destination address
;dnSource isolates the addressing bits with Dn being the source address

dnDest:
            ;**Used for isolating addressing bits when Dn is the destination**
            
            ;*SOURCE*
            ;Jumps to helper subroutine to isolates and return the address mode & register stored in bits 0 - 5
            ;D6 will contain mode & D7 will contain the register after this instruction
            BSR         isolateAddressBit0to5
            
            ;*Print source address*
            BSR         addressModeSR
            
            ;Print comma after source address
            LEA         printComma,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;*DESTINATION*
            ;Jumps to helper subroutine to isolates and return the register stored in bits 9 - 11
            ;D7 will contain the register after this instruction
            BSR         isolateRegisterBit9to11
            
            ;Save #%000 into D6 to specify data register mode
            MOVE.B      #0,D6
            
            ;*Print destination address*
            BSR         addressModeSR

            BRA         update
            
dnSource:
            ;**Used for isolating addressing bits when Dn is the destination**
                        
            ;*SOURCE*
            ;Jumps to helper subroutine to isolates and return the register stored in bits 9 - 11
            ;D7 will contain the register after this instruction
            BSR         isolateRegisterBit9to11
            
            ;Save #%000 into D6 to specify data register mode
            MOVE.B      #0,D6
            
            ;*Print Source address*
            BSR         addressModeSR
            
            ;Print comma after source address
            LEA         printComma,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;*DESTINATION*
            ;Jumps to helper subroutine to isolates and return the address mode & register stored in bits 0 - 5
            ;D6 will contain mode & D7 will contain the register after this instruction
            BSR         isolateAddressBit0to5
            
            ;*Print destination address*
            BSR         addressModeSR

            BRA         update
                   
isolateAddressBit0to5:
;Helper subroutine for isolating the address stored within bits 0-5
;Stores address mode in D6
;Stores address register in D7

            ;======Isolate Effective Address Mode (M) Bits=======
            CLR.L       D2
            
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating Mode bits
            MOVE.B      #3,D3             ;Start bit index = 3
            MOVE.B      #3,D4             ;Number of bits needed = 3
            
            ;Jumps to getBits and returns with isolated bits in D2
            JSR         getBits
            
            ;Save M bit into ***D6*** for later use in addressModeSubroutine
            MOVE.B      D2,D6
            
                     
            ;======Isolate Effective Address Register (Xn) Bits=======
            CLR.L       D2
            
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating Xn bits
            MOVE.B      #0,D3             ;Start bit index = 0
            MOVE.B      #3,D4             ;Number of bits needed = 3
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            ;Save Xn register bit into ***D7*** for later use in addressModeSR
            MOVE.B      D2,D7
            
            RTS

isolateRegisterBit9to11:
;Helper subroutine for isolating the register stored within bits 9-11
;Stores the address register in D7

            ;======Isolate Register Bits=======
            CLR.L       D2
            CLR.L       D6
            CLR.L       D7
            
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating register bits
            MOVE.B      #9,D3             ;Start bit index = 9
            MOVE.B      #3,D4             ;Number of bits needed = 3
            
            ;Jumps to getBits and returns with isolated bit in D2
            BSR         getBits
            
            ;Save register bit into ***D7*** for later use in addressModeSR
            MOVE.B      D2,D7

            RTS
            
*-----------------------------------------------------------
* Print Sizes
*-----------------------------------------------------------
printSizeSubroutine:
            ;Prints the apporpriate size
            ;PARAMETER:
            ;D2 = the size bits
            
            ;Compare to which size is being moved for the opcode
            CMP.B      #%00,D2
            BEQ        PByte
            
            CMP.B      #%01,D2
            BEQ        PWord
            
            CMP.B      #%10,D2
            BEQ        PLong
            
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
            LEA        printSIZEL,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            ;NOTE: no error message for #%11 so ASd/LSd can use this subroutine
            RTS
            
            
*-----------------------------------------------------------
* Addressing Mode Implementation
*-----------------------------------------------------------
addressModeSR:
            ;Prints address according to the parameters passed in
            ;PARAMETERS:
            ;D6 = mode
            ;D7 = register

            ;Data register direct
            CMP.B       #%000,D6
            BEQ         DRD
            
            ;Address register direct
            CMP.B       #%001,D6
            BEQ         ARD
            
            ;Address register indirect
            CMP.B       #%010,D6
            BEQ         ARI
            
            ;Post Increment
            CMP.B       #%011,D6
            BEQ         PI
            
            ;Pre Decrement
            CMP.B       #%100,D6
            BEQ         PD
DRD:
            ;Print D __
            LEA         printDRD,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Print register number
            MOVE.L      #3,D0
            MOVE.L      D7,D1
            TRAP        #15
            
            RTS
ARD:
            ;Print A __
            LEA         printARD,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Print register number
            MOVE.L      #3,D0
            MOVE.L      D7,D1
            TRAP        #15
            
            RTS
ARI:
            ;Print (A __ )
            LEA         printARI,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Print register number
            MOVE.L      #3,D0
            MOVE.L      D7,D1
            TRAP        #15
            
            ;Print closing ')'
            LEA         printARI2,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            RTS
PI:
            ;Print (A __)+
            LEA         printPI,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Print register number
            MOVE.L      #3,D0
            MOVE.L      D7,D1
            TRAP        #15
            
            ;Print closing ')+'
            LEA         printPI2,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            RTS
PD:
            ;Print -(A __)
            LEA         printPD,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Print register number
            MOVE.L      #3,D0
            MOVE.L      D7,D1
            TRAP        #15
            
            ;Print closing ')'
            LEA         printPD2,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            RTS
IA:
            ;Print #$ ______
            RTS
ALA:
            ;Print $-------- (8 digits)
            RTS
AWA:
            ;Print $---- (4 digits)
            RTS


*-----------------------------------------------------------
* Print Instructions for NOP and RTS
*-----------------------------------------------------------
printN:
            LEA        printNOP,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            BRA        update

printMRTS:
            LEA        printRTS,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            BRA        update
;-----------------------------------------------------------
;ERROR MESSAGES FOR I/O portion
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

;-----------------------------------------------------------
;OPCODE Messages
;-----------------------------------------------------------
printNOP    DC.B        CR,LF,'NOP',0
printMOVE   DC.B        CR,LF,'MOVE',0
printMOVEM  DC.B        CR,LF,'MOVEM',0
printADD    DC.B        CR,LF,'ADD',0
printSUB    DC.B        CR,LF,'SUB',0
printMULS   DC.B        CR,LF,'MULS.W ',0
printDIVU   DC.B        CR,LF,'DIVU.W ',0
printLEA    DC.B        CR,LF,'LEA ',0
printAND    DC.B        CR,LF,'AND',0
printNOT    DC.B        CR,LF,'NOT',0
printLSL    DC.B        CR,LF,'LSL',0
printLSR    DC.B        CR,LF,'LSR',0
printASL    DC.B        CR,LF,'ASL',0
printASR    DC.B        CR,LF,'ASR',0
printBLT    DC.B        CR,LF,'BLT',0
printBGE    DC.B        CR,LF,'BGE',0
printBEQ    DC.B        CR,LF,'BEQ',0
printJSR    DC.B        CR,LF,'JSR',0
printRTS    DC.B        CR,LF,'RTS',0
printBRA    DC.B        CR,LF,'BRA',0
printMAS    DC.B        CR,LF,'AS',0
printMLS    DC.B        CR,LF,'LS',0
printL      DC.B        'L',0
printR      DC.B        'R',0


;-----------------------------------------------------------
;Size Messages
;-----------------------------------------------------------
printSIZEB   DC.B        '.B ',0
printSIZEW   DC.W        '.W ',0
printSIZEL   DC.L        '.L ',0

;-----------------------------------------------------------
;Addressing Mode Messages
;-----------------------------------------------------------
printDRD      DC.B        'D',0
printARD      DC.B        'A',0
printARI      DC.B        '(A',0
printARI2     DC.B        ')',0
printIA       DC.B        '#',0
printPI       DC.B        '(A',0
printPI2      DC.B        ')+',0
printPD       DC.B        '-(A',0
printPD2      DC.B        ')',0
;printAA       DC.B        ''   /TBD

printComma    DC.B        ',',0
printSpace    DC.B        ' ',0

theEnd      DC.B        CR,LF,'You are now ending the program',0

;-----------------------------------------------------------
;ERRORS
;-----------------------------------------------------------
invalCh     DC.B        'ERROR: Invalid Characters used',CR,LF,0
odd         DC.B        'ERROR: Cannot start at odd memory location',CR,LF,0
manyChar    DC.B        'ERROR: Cannot have more than 6 characters in the address',CR,LF,0
endG        DC.B        'ERROR: The ending address cannot be less than the starting address',CR,LF,0
sizeError   DC.B        'ERROR: Invalid size instruction',0

;-----------------------------------------------------------
;Ending function that ends our program 
;-----------------------------------------------------------
ending:
            LEA         theEnd,A1
            MOVE        #14,D0
            TRAP        #15
            
            END         MAIN 













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
