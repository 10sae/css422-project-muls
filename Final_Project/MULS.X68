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

;Used for MOVEM
counter:    DC.B        $0
totalCount: DC.B        $0
dORa:       DC.B        $0
curAdd:     DC.W        $0
movemAdd:   DC.B        $0
listSize:   DC.B        $0
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
                     
            
            MOVEM.L     (A5)+,D0-D2/D5-D7/A0-A3/A6
            MOVEM.L     (A5),D0-D2/D5-D7/A0-A3/A6
            MOVEM.L     D0-D2/D5-D7/A0-A3/A6,-(A5)
            MOVEM.L     $1234,D0-D5/D7/A0-A6
            MOVEM.L     $3000,A0-A6
            MOVEM.L     D1/D3-D5/A2-A7,$3004
            MOVEM.L     D0-D5/A2-A7,$3030
            MOVEM.L     D0-D5/A2-A7,-(A7)
            ;MOVEM.L     $3212,D0/D2/A5/A7
            ;MOVEM.L     D0-D5/D7/A0-A6,-(A7)     
            
;==========================            
            
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
            ;D7 is if we're working with the first or second prompt, used in the more checks section. 
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
            CMP.B       #8, D1
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
            ;We will be printing out the address, regardless if the opcode is valid or not
            LEA         AddressNum,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Print out the address
            MOVE.L      #15,D0
            MOVE.L      #16,D2
            MOVE.L      A2,D1
            TRAP        #15
            
            LEA         printSpace,A1
            MOVE.B      #14,D0
            TRAP        #15

            ;--------------------------------------------------------
            ;Check for NOP or RTS
            ;--------------------------------------------------------
            
            ;Move the NOP binary value for comparing
            MOVE.L      #%0100111001110001,D2
            
            ;Check and see i the instruction is NOP
            CMP.W       (A2),D2
            BEQ         printMNOP
            
            ;Move the RTS binary value for comparing
            MOVE.L      #%0100111001110101,D2
            
            ;Check and see if the instruction is RTS
            CMP.W       (A2),D2
            BEQ         printMRTS
            
            ;Clear the contents for reusing
            CLR.L       D2
            
            ;--------------------------------------------------------
            ;Check for ADDI or SUBI, check for four 0's since it's the only
            ;opcode with this pattern
            ;--------------------------------------------------------  
            ;Move the value in A2 to a temp register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating the left most hand 4 bits of D2 using getBits
            MOVE.B      #12,D3
            MOVE.B      #4,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            CMP.B       #%0000,D2
            BEQ         M0000
            
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
            
            ;BSR         invalOpCode
            
            BRA         ending
            
            
            

           
update:
            *=====Important if we've done any Immediate or Absolute addressing=====*
            ;If we've done any Immediate or Absolute addressing, then we would have made use of A6. 
            ;A6 would point to the last word in instruction and thus pointing to a larger address value than A2, 
            ;because A2 always points at the the first word in an instruction (opcode).
            CMP.L       A6,A2
            BGE         skipA6
            
            ;If A6 points to an address larger than the one A2 points to then we update A2 to point to where A6 points
            MOVEA.L     A6,A2
            
skipA6:
            ;Check and see if we are at the ending hex
            CMP.L      endHex,A2
            BGT        ending

            ;Update address in A2
            ADDA.W      #2,A2
            
            
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
* 
*
*
* OpCode Implementation
*
*
*
*-----------------------------------------------------------


*-----------------------------------------------------------
* ADDI/SUBI INSTRUCTION
*-----------------------------------------------------------
M0000:
            CLR.L       D2
            CLR.L       D3
            
            ;Copy the address values into a register to check for ADDI or SUBI
            MOVE.W      (A2),D2
            
            ;Passing in paramters for isolating bits
            MOVE.B      #8,D3
            MOVE.B      #4,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            ;--------------------------------------------------------
            ;Check for ADDI
            ;--------------------------------------------------------
            CMP.B       #%0110,D2
            BEQ         MADDI
           
            ;--------------------------------------------------------
            ;Check for SUBI
            ;--------------------------------------------------------
            CMP.B       #%0100,D2
            BEQ         MSUBI

MADDI:
            LEA         printADDI,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            CLR.L       D2
            CLR.L       D3
            
            ;======Isolate Size (S) Bits======
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating size bits
            MOVE.B      #6,D3
            MOVE.B      #2,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            ;Jumps to printSizeSubroutine and returns after size has been printed
            BSR         printSizeSubroutine
            
            ;Let's store the size indicator since it will help us determine how many times
            ;we have to iterate through addresses to print out the whole instruction
            ;We will use A4 as the register to temporary store the size
            MOVE.W      D2,A4
            MOVE.B      D2,$2000
            
            ;Clear the register so we can reuse it
            CLR.L       D2
            
            MOVE.B      (A2),D2
            
            ;Just before manipulating A2's value, let's store a copy of it so we can use the unmanipulated address
            ;This is meant so we can use the copy to figure out the destination addrresing mode
            MOVE.L      A2,A3
            
            BSR         mEffect
            
            CLR.L       D3
            
            BRA         update
            
            
MSUBI:
            LEA         printSUBI,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            CLR.L       D2
            CLR.L       D3
            
            ;======Isolate Size (S) Bits======
            ;Copy the address values into a register
            MOVE.W      (A2),D2
            
            ;Passing in parameters for isolating size bits
            MOVE.B      #6,D3
            MOVE.B      #2,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            ;Jumps to printSizeSubroutine and returns after size has been printed
            BSR         printSizeSubroutine
            
            ;Let's store the size indicator since it will help us determine how many times
            ;we have to iterate through addresses to print out the whole instruction
            ;We will use A4 as the register to temporary store the size
            MOVE.W      D2,A4
            MOVE.B      D2,$2000
            
            ;Clear the register so we can reuse it
            CLR.L       D2
            
            MOVE.B      (A2),D2
            
            ;Just before manipulating A2's value, let's store a copy of it so we can use the unmanipulated address
            ;This is meant so we can use the copy to figure out the destination addrresing mode
            MOVE.L      A2,A3
            
            BSR         mEffect
            
            CLR.L       D3
            
            BRA         update

            
mEffect:
            ;Male D6 #%111 since the source will always be an immediate value 
            MOVE.B      #7,D6
            ;Make D7 #%100 since the source will always be an immediate value
            MOVE.B      #4,D7     

            ;Print source address
            BSR         addressModeSR
            
            ;Print the comma after the source address
            LEA        printComma,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            ;Jump to a helper subroutine which will help isolate bits for the address mode and register
            BSR        isoAddBit0to5
            
            ;Print source address
            BSR        addressModeSR
            
            RTS            
            
            
isoAddBit0to5:
            ;===Isolate the Destination Mode (M)Bits===
            CLR.L      D2
            
            ;Copy the address value into a register
            MOVE.W     (A3),D2
            
            ;Passing in parameters for isolating Mode bits
            MOVE.B     #3,D3
            MOVE.B     #3,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            JSR        getBits
            
            ;Save M bit into ***D6*** for later use in addressModeSubroutine
            MOVE.B     D2,D6
            
            ;===Isolate the Destination Address Register (Xn)Bits===
            CLR.L      D2
            
            ;Copy the address values into a register
            MOVE.W     (A3),D2
            
            ;Passing in parameters for isolating Xn bits
            MOVE.B     #0,D3
            MOVE.B     #3,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            JSR        getBits
            
            ;Save Xn register bit into ***D7*** for later use in addressModeSR
            MOVE.B      D2,D7

            RTS
            
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
            MOVE.B      #12,D3             
            MOVE.B      #2,D4             
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits  
            
            ;Indicate to our print function we are doing this for the MOVE opcode
            MOVE.B      #1,D3
            
            ;Jumps to printSizeSubroutine and returns after size has been printed
            BSR         printSizeSubroutine
            
            ;Let's store the size indicator since it will help us determine how many times
            ;we have to iterate through addresses to print out the whole instruction
            ;We will use A4 as the register to temporary store the size
            MOVE.W      D2,A4
            MOVE.B      D2,$2000

            ;Clear the register so we can reuse it
            CLR.L       D2
            
            MOVE.W      (A2),D2
            
            ;Just before manipulating A2's value, lets store a copy of it so we can use the unmanipulated address
            ;This is meant so we can use the copy to figure out the destination addressing mode
            MOVE.L      A2,A3

            BRA         mSourceDest
            
          
;======Helper function to find the destination for MOVE======
mSourceDest:
            ;SOURCE
            ;Jump to a helper subroutine which will help isolate bits for the address mode and register
            BSR        isolateAddressBit0to5
            
            ;Print source address
            BSR        addressModeSR
            
            ;Print the comma after the source address
            LEA        printComma,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            ;DESTINATION
            ;Jump to a helper subroutine which will help isolate bits for the address mode and register
            BSR        isolateAddressBit6to11
            
            ;Print destination address
            BSR        addressModeSR
            
            CLR.L      D3
            
            BRA        update
            

isolateAddressBit6to11:
            ;===Isolate the Destination Mode (M)Bits===
            CLR.L      D2
            
            ;Copy the address value into a register
            MOVE.W     (A3),D2
            
            ;Passing in parameters for isolating Mode bits
            MOVE.B     #6,D3
            MOVE.B     #3,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            JSR        getBits
            
            ;Save M bit into ***D6*** for later use in addressModeSubroutine
            MOVE.B     D2,D6
            
            ;===Isolate the Destination Address Register (Xn)Bits===
            CLR.L      D2
            
            ;Copy the address values into a register
            MOVE.W     (A3),D2
            
            ;Passing in parameters for isolating Xn bits
            MOVE.B     #9,D3
            MOVE.B     #3,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            JSR        getBits
            
            ;Save Xn register bit into ***D7*** for later use in addressModeSR
            MOVE.B      D2,D7

            RTS
            
            
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
            LEA         printMOVEM,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ***Isolate Size Bit***
            ;Clear D2 and recopy it to check for Size bit
            CLR.L       D2
            MOVE.W      (A2),D2
            
            ;Pass in paramters for isolating bit 6
            MOVE.B      #6,D3
            MOVE.B      #1,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits
            
            ;Print size
            JSR         printMOVEMSize
            
            ;Clear any value in our gloabal variable just in case
            MOVE.B      #0,movemAdd
            
            ;Next we are going to get the addressing mode to determine how we print the register list
            ;Isolate bits 0 to 5
            JSR         isolateAddressBit0to5
            ;Let's store the addressing mode in our global variable
            MOVE.B      D6,movemAdd
            
            CLR.L       D3
            CLR.L       D4
            CLR.L       D6
            
            
            ***Isolate Direction bit
            ;Clear D2 and recopy it to check for D bit
            CLR.L       D2
            MOVE.W      (A2),D2
            
            ;Pass in parameters for isolating bit 10
            MOVE.B      #10,D3
            MOVE.B      #1,D4
            
            ;Jumps to getBits and returns with isolated bits in D2
            BSR         getBits

            ***Determine the direction of the instruction***
            CMP.B       #0,D2
            BEQ         ListToMem

            ;Memory to Register List
            CMP.B       #1,D2
            BEQ         MemToList  
                       
ListToMem:
            ***SOURCE(Register List)  
            CLR.L       D2

            ;A3 will act as our temp variable 
            MOVE.L      $00000000,A3
            MOVEA.W     A2,A3
            
            ;Reset 
            MOVE.B     #$00,totalCount
            MOVE.B     #$00,listSize
         
            MOVE.B      #1,curAdd
            
            ;Go find the register list
            BSR         check
            
ListToMem2:
            ;Print the comma after the source address
            LEA         printComma,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ***DESTINATION(Memory)
            ;Clear D2 and recopy it to check for bits 0-5 (to print memory addressing)
            CLR.L       D2
            
            MOVE.W      (A2),D2
            
            ;Isolate bits 0 to 5
            JSR         isolateAddressBit0to5
            
            CMP.B       #%111,D6
            BSR         absoluteAddressMOVEM
            
            ;Clear A6 since we will need this for later
            MOVE.L      #00000000,A6
            
            ;Print memory address
            BSR         addressModeSR
            
            CLR.L      D3
            
            BRA        update


MemToList:
            ***SOURCE(Memory)***
            ;Clear D2 and recopy it to check for bits 0-5 (to print memory addressing)
            CLR.L       D2            
            
            MOVE.W      (A2),D2
            
            ;Use A3 as a temp address to be able to access the memory address
            MOVE.L      #00000000,A3
            MOVEA.W     A2,A3

            ;Isolate addressing bits 0 to 5
            JSR         isolateAddressBit0to5
            
            CMP.B       #%111,D6
            BSR         absoluteAddressMOVEM
           
            ;Clear A6 since we will need this for later
            MOVE.L      #00000000,A6
            
            ;Print memory address
            BSR         addressModeSR
            
            ;Print the comma after the source address
            LEA         printComma,A1
            MOVE.B      #14,D0
            TRAP        #15
                        
            ;Reset 
            MOVE.B      #$00,totalCount
            MOVE.B      #$00,listSize
            
            MOVE.B      #0,curAdd
            
            ;Go find the register list
            BSR         check
    
            
absoluteAddressMOVEM:
            ADDA.W      #2,A2

            RTS                     
              
check:
            CMP.B       #0,(totalCount)
            BEQ         findList

            CMP.B       #8,(totalCount)
            BEQ         findList2
   
            ;We go back to ListToMem which was our starting point
            CMP.B       #1,(curAdd)
            BEQ         ListToMem2
             
            ;If we arrive here, we assume that we started in MemToList      
            CLR.L      D3
            
            BRA        update


findList:
            ;Set up the temp register to the register list
            ADDA.W      #2,A3

            MOVE.W      (A3),D2

            ;Clear some registers so we can have a counter
            ;and two registers to hold a beginning index and then ending index
            CLR.L       D4
            CLR.L       D5
            CLR.L       D6
            CLR.L       D7  ;Holds the actual value for manipulation
            
            ;Set D7 to indicate we are doing the first bit check
            MOVE.W      (A3),D7
            
            
            ;===Setting Up Variables===            
            ;Indicate we are at the start of the word for our counter
            MOVE.B      #0,counter
            ;==========================
            
            ;The (dORa) variable changes because it must be the opposite of findList 
            CMP.B       #3,movemAdd
            BEQ         setA
            
            BRA         setD

         
findList2:           
            CLR.L       D7
            MOVE.B      (A3),D7
            
            ;===Setting Up Variables===
            ;Indicate we are at the start of the word for our counter
            MOVE.B      #0,counter
            ;==========================
            
            ;The (dORa) variable changes because it must be the opposite of findList            
            CMP.B       #3,movemAdd
            BEQ         setD
            
            BRA         setA
           
 
setD:
            MOVE.B      #0,dORa
            
            ;Go through a loop and rotate bits twice for the D registers
            BSR         bitLoop
 
setA:
            MOVE.B      #1,dORa
            
            ;Go through a loop and rotate bits twice for the D registers
            BSR         bitLoop

bitLoop:

            ;If our counter is 8, then we must finish printing the list
            CMP.B       #8,counter
            BEQ         check

            MOVE.W      D7,D2
            
            ;We will use getBits to get the right-most bit (Stored in D2)
            MOVE.B      #0,D3  ;The starting index of the word
            MOVE.B      #1,D4  ;How many bits we want

            BSR         getBits
            
            ;If the bit is 0, then that means we must print out some values
            CMP.B       #0,D2
            BEQ         skipBit

            BSR         printSingle
            
skipBit:
            ;Increment the rest of our variables to set up the loop again
            ADD.B       #1,counter
            ADD.B       #1,totalCount
            
            LSR.L       #1,D7
            
            BRA         bitLoop
 

printSingle:
            ;update number of registers included in the list
            ADD.B       #1,listSize
            ;Check and see if we should print D or A
            CMP.B       #0,(dORa)
            BEQ         singleDReg
            
            CMP.B       #1,(dORa)
            BEQ         singleAReg

singleDReg:
            CMP.B       #1,listSize
            BEQ         skipSlashD
       
            BSR         pSlash
            
skipSlashD:
            LEA         printDRD,A1
            MOVE.B      #14,D0
            TRAP        #15

            ;Print out the register number
            CLR.L       D1
            MOVE.B      (counter),D1
            MOVE.B      #3,D0
            TRAP        #15           
            
            ADD.B       #1,counter
            ADD.B       #1,totalCount
            
            LSR.L       #1,D7
            
            BRA         bitLoop
 


singleAReg:
            CMP.B       #1,listSize
            BEQ         skipSlashA
       
            BSR         pSlash
            
skipSlashA:
            LEA         printARD,A1
            MOVE.B      #14,D0
            TRAP        #15

            ;Print out the register number
            CLR.L       D1
            MOVE.B      (counter),D1
            MOVE.B      #3,D0
            TRAP        #15

            ADD.B       #1,counter
            ADD.B       #1,totalCount
            
            LSR.L       #1,D7
            
            BRA         bitLoop
         
pSlash:
            LEA         printSlash,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            RTS       
        
       
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
            ;Distinguish NOT from "MOVE to SSR"                 
            
            CLR.L      D2
            ;Move the address into the register to check for size
            MOVE.W     (A2),D2
            
            ;Pass in parameters for isolating bits 6,7
            MOVE.B     #6,D3
            MOVE.B     #2,D4
            
            ;Jump to getbits and return with isolated bits
            BSR        getbits

            ;This was meant for invalid opcode testing
            ;CMP.B      #%11,D2
            ;BRA        InOpCode     

            LEA        printNOT,A1
            MOVE.B     #14,D0
            TRAP       #15    
            
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
            CLR.L       D0
            CLR.L       D1
            CLR.L       D2
            CLR.L       D3
            CLR.L       D4
      
            ;Moves the instruction into D2
            MOVE.W     (A2),D2
            
            ;Setting up parameters for getBits - isolating bits 11-8
            MOVE.B      #8,D3             ;Start bit index = 8
            MOVE.B      #4,D4             ;Number of bits needed = 4
            
            ;calls getBits subroutine, D2 now has the four condition bits of the Bcc/BRA instruction. 
            BSR         getBits
            
            ;If the condition bits are 0000, the instruction is a BRA instruction. 
            CMP.L       #%0000,D2
            BEQ         MBRA
            
            ;0100 = BCC
            CMP.L       #%0100,D2
            BEQ         MBCC
            
            ;1101 = BLT
            CMP.L       #%1101,D2
            BEQ         MBLT
            
            ;1100 = BGE
            CMP.L       #%1100,D2
            BEQ         MBGE
            
            ;0111 = BEQ
            CMP.L       #%0111,D2
            BEQ         MBEQ

MBRA:
    ;condition bits (11-8) are 0000
            LEA         printBRA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         bccOffset

MBCC:
    ;condition bits (11-8) are 0100     
            LEA         printBCC,A1
            MOVE.B      #14,D0
            TRAP        #15

            BRA         bccOffset

MBLT:
    ;condition bits (11-8) are 1101
            LEA         printBLT,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         bccOffset

MBGE:
    ;condition bits (11-8) are 1100
            LEA         printBGE,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         bccOffset

MBEQ:            
    ;condition bits (11-8) are 0111
            LEA         printBEQ,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            BRA         bccOffset         

bccOffset:
    ;each variation of Bcc, BLT, BEQ, BRA, etc has the same format for the offset bits. Bits 0-7 are either the offset themself, or
    ;tell us where to look. If it contains $00, then 16-bit offset. If it contains $FF, 32-bit offset.
    
            ;Moves the branch family instruction into D2
            MOVE.W     (A2),D2
            
            ;Setting up parameters for getBits - isolating bits 0-7
            MOVE.B      #0,D3             ;Start bit index = 0
            MOVE.B      #8,D4             ;Number of bits needed = 8

            ;calls getBits subroutine, D2 now has the offset bits
            BSR         getBits
            
            ;If the offset bits are $00, we need to look at the next 16 bits for the offset.
            CMP.L       #%00000000,D2
            BEQ         bit16Displacement
            
            ;If the offset bits are $FF, we need to look at the next 32 bits for the offset.
            CMP.L       #%11111111,D2
            BEQ         bit32Displacement
            
            ;If neither of the above two cases are true, we continue to 8bitDisplacement. 
            
bit8Displacement:
            ;We're here if the 8-bit displacement isn't $00 or $FF, and D2 already has the offset bits.
            ;D2 is a twos complement integer specifying the number of bytes between the branch instruction 
            ;and the next instruction to be executed (if the condition is met) 
            
            ;A2 is the address of the current instruction we're working with
            MOVEA.L      A2,A6
          
            CMP.B       #$80,D2   ;Check to see if the two's complement value is positive/negative, and branch accordingly.
            BGE         sub8Bits
            
            BRA         add8Bits

add8Bits:
            ADD.W       D2,A6
            BRA         continue8Bits
sub8Bits:
            ;If the displacement is negative, convert it into a regular value and subtract it from the address.
            NOT.B       D2      ;inverts D2
            SUB.B       #1, D2  ;usually we would add 1 to turn this two's complement into a regular number, but we have to 
                                ;account for the length of the instruction's opperation, which is 2 bytes, so we subtract 1.
            SUB.W       D2,A6   
            
            BRA         continue8Bits

continue8Bits:
            
            ;Output $
            LEA         printA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Output destination address
            MOVE.L      #16,D2  ;sets the base for output - hexadecimal
            MOVE.L      #15,D0  ;task number
            MOVE.L      A6,D1
            TRAP        #15
            
            MOVE.L      #$0,A6
            BRA         update
bit16Displacement:
            ;Getting the next 16 bits
            MOVE.W      (A2)+,D2
            MOVE.W      (A2),D2
            MOVEA.L      A2,A6
          
            CMP.L       #$8000,D2   ;Check to see if the two's complement value is positive/negative, and branch accordingly.
            BGE         sub16Bits
            
            BRA         add16Bits

            
add16Bits: 
            ADD.W       D2,A6
            BRA         continue16Bits

sub16Bits:  
            ;If the displacement is negative, convert it into a regular value and subtract it from the address.
            NOT.W       D2      ;inverts D2
            SUB.W       #3, D2  ;usually we would add 1 to turn this two's complement into a regular number, but we have to 
                                ;account for the length of the instruction's opperation, which is 4 bytes, so we subtract 3.
            SUB.W       D2,A6   
            BRA         continue16Bits
            
continue16Bits:
            ;Output $
            LEA         printA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Output destination addres
            MOVE.L      #16,D2  ;sets the base for output - hexadecimal
            MOVE.L      #15,D0  ;task number
            MOVE.L      A6,D1
            TRAP        #15
            
            MOVE.L      #$0,A6
            BRA         update
            
bit32Displacement:      ;Getting the next 32 bits
            MOVE.L      (A2)+,D2
            MOVE.L      (A2),D2
            MOVEA.L     A2,A6
          
            CMP.L       #$80000000,D2   ;Check to see if the two's complement value is positive/negative, and branch accordingly.
            BGE         sub32Bits
            
            BRA         add32Bits

add32Bits:
            ADD.L       D2,A6
            BRA         continue32Bits

sub32Bits:              ;If the displacement is negative, convert it into a regular value and subtract it from the address. 
            NOT.L       D2      ;inverts D2
            SUB.L       #5,D2   ;usually we would add 1 to turn this two's complement into a regular number, but we have to 
                                ;account for the length of the instruction's opperation, which is 6 bytes, so we subtract 5.
            SUB.L       D2,A6   
            BRA         continue32Bits

continue32Bits:      
            ;Output $
            LEA         printA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Output destination addres
            MOVE.L      #16,D2  ;sets the base for output - hexadecimal
            MOVE.L      #15,D0  ;task number
            MOVE.L      A6,D1
            TRAP        #15
      
            MOVE.L      #$0,A6      
            BRA         update

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
            
            ;Let's store the size indicator since it will help us determine how many times
            ;we have to iterate through addresses to print out the whole instruction
            ;We will use A4 as the register to temporary store the size
            MOVE.W      D2,A4
            MOVE.B      D2,$2000
            
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
; Subroutine to enter when the instruction begins with 1110
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

; Subroutine to enter if instruction is given data register to shift
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


; Resumes printing data register shift instruction after printing AS or LS
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

;Subroutine to enter if amount to shift is an immediate address            
ImmediateCount
            ;Print #$
            LEA        printIA,A1
            MOVE.B     #14,D0
            TRAP       #15
            
            ;*Data Register to be Shifted*
            CLR.L       D2
            
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
            
            MOVE.L      D2, D1
            BSR         ImmediateCount2
;Subroutine to print shift count           
ImmediateCount2
            ;Print shift count
            MOVE.B      #3,D0
            TRAP        #15
            BSR         RegShift2
;Subroutine to enter if shift count is 8
ShiftEight  ;Move 8 into D1    
            CLR.L       D1
            MOVE.B      #8, D1
            BSR         ImmediateCount2
            
; Subroutine to enter when the instruction is given a memory address to shift                         
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
            
; Continues memory address shift after printing AS or LS
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

; Prints LS
MLS:
            LEA        printMLS,A1
            MOVE.B     #14,D0
            TRAP       #15
            RTS
; Prints AS
MAS:
            LEA        printMAS,A1
            MOVE.B     #14,D0
            TRAP       #15
            RTS

;Subroutine for the direction if shifting a memory address
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

;Subroutine for the direction if shifting a data register        
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
       
            ;Let's store the size indicator since it will help us determine how many times
            ;we have to iterate through addresses to print out the whole instruction
            ;We will use A4 as the register to temporary store the size
            MOVE.W      D2,A4
            MOVE.B      D2,$2000
            
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
            
            ;Since MOVE uses different bits for size, we must check and see if the opcode is MOVE
            CMP.B      #1,D3
            BEQ        printMOVESize
            
            ;Compare to which size is being moved for the opcode
            CMP.B      #%00,D2
            BEQ        PByte
            
            CMP.B      #%01,D2
            BEQ        PWord
            
            CMP.B      #%10,D2
            BEQ        PLong
         
printMOVESize:
            ;Now that we know we have a MOVE opcode
            ;Compare to which size is being moved for the opcode
            CMP.B      #%01,D2
            BEQ        PByte

            CMP.B      #%11,D2
            BEQ        PWord            
  
            CMP.B      #%10,D2
            BEQ        PLong
            
printMOVEMSize:
            ;Now that we know we have a MOVEM opcode
            ;Compare to which size is being moved for the opcode
            CMP.B      #%0,D2
            BEQ        PWord
            
            CMP.B      #%1,D2
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
            
            ;Immediate/Absolute Addressing
            CMP.B       #%111,D6
            BEQ         otherModes
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

otherModes:
            CMP.W       A6,A2
            
            BLT         SKIPCOPY  

             *=====Important step for making sure we have access to where A2 orignally points=====*
            MOVEA.L     A2,A6 


SKIPCOPY:            
            
            ;Branch to Immediate if register bits are %100       
            CMP.B       #%100,D7
            BEQ         Immediate
            
            ;Otherwise, branch to Absolute
            BRA         Absolute
            
        
                   
Immediate:
            ;Print #
            LEA         printIA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Since we are dealing with addresses, we update our address to account for the actual address value
            ;We will be able to access the contents of either size B or W
            ADDA.W      #2,A2         

            ;If the value is a Long then branch to ImmLong to get the remaining bits of the value
            CMP.B       #%10,$2000
            BEQ         IMDLong
            
            ;If we don't branch, then we assume we're printing out a byte or word      
            MOVE.L      #3,D0
            MOVE.W      (A2),D1
            TRAP        #15
            
            RTS
            
            
            
Absolute:
            ;Print $
            LEA         printA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Point to the next word (contains memory address)
            ADDA.W      #2,A6
            
            ;If the value is a Long then branch to AbsLong to get the remaining bits of the value
            CMP.B       #%001,D7
            BEQ         AbsLong
            
            ;Print out the value in the address if it's a word
            CLR.L       D1
            
            MOVE.W      #15,D0
            MOVE.W      #16,D2
            MOVE.W      (A6),D1
            TRAP        #15
            
            RTS
            
AbsLong:            
            ;Place the current value into a temp register
            MOVE.W      (A6),D4
            
            ;Shift the bits so we can enter the rest of the values
            MOVE.B      #16,D7
            LSL.L       D7,D4
            
            ;Increment A6 to account for the next values in the instruction
            ADDA.W      #2,A6
            
            ;Move the rest of the machine code into our register
            ;This register should have the whole long values
            MOVE.W      (A6),D4
            
            ;Print the Long address
            CLR.L       D1
            
            MOVE.L      #15,D0
            MOVE.L      #16,D2
            MOVE.L      D4,D1
            TRAP        #15
            
            RTS    
        
IMDLong:
            *********USED FOR IMMEDIATE LONGS ONLY***************
            
            ;Place the current value into a temp register
            MOVE.W      (A2),D4
            
            ;Shift the bits so we can enter the rest of the values
            MOVE.B      #16,D7
            LSL.L       D7,D4
            
            ;Increment A2 to account for the next values in the machine code
            ADDA.W      #2,A2
            
            ;Move the rest of the machine code into our register
            ;This register should have the whole long values
            MOVE.W      (A2),D4
            
            ;Print out the value in the address
            MOVE.L      #3,D0
            MOVE.L      D4,D1
            TRAP        #15
            
            RTS


*-----------------------------------------------------------
* Print Instructions for NOP and RTS
*-----------------------------------------------------------
printMNOP:
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
AddressNum  DC.B        CR,LF,'Address: ',0

;-----------------------------------------------------------
;OPCODE Messages
;-----------------------------------------------------------
printNOP    DC.B        'NOP',0
printMOVE   DC.B        'MOVE',0
printMOVEM  DC.B        'MOVEM',0
printADD    DC.B        'ADD',0
printADDI   DC.B        'ADDI',0
printSUB    DC.B        'SUB',0
printSUBI   DC.B        'SUBI',0
printMULS   DC.B        'MULS.W ',0
printDIVU   DC.B        'DIVU.W ',0
printLEA    DC.B        'LEA ',0
printAND    DC.B        'AND',0
printNOT    DC.B        'NOT',0
printLSL    DC.B        'LSL',0
printLSR    DC.B        'LSR',0
printASL    DC.B        'ASL',0
printASR    DC.B        'ASR',0
printBLT    DC.B        'BLT',0
printBGE    DC.B        'BGE',0
printBEQ    DC.B        'BEQ',0
printBCC    DC.B        'BCC ',0
printJSR    DC.B        'JSR ',0
printRTS    DC.B        'RTS',0
printBRA    DC.B        'BRA',0
printMAS    DC.B        'AS',0
printMLS    DC.B        'LS',0
printL      DC.B        'L',0    
printR      DC.B        'R',0
;-----------------------------------------------------------
;Size Messages
;-----------------------------------------------------------
printSIZEB  DC.B        '.B ',0
printSIZEW  DC.W        '.W ',0
printSIZEL  DC.L        '.L ',0

;-----------------------------------------------------------
;Addressing Mode Messages
;-----------------------------------------------------------
printDRD      DC.B        'D',0
printARD      DC.B        'A',0
printARI      DC.B        '(A',0
printARI2     DC.B        ')',0
printIA       DC.B        '#',0
printA        DC.B        '$',0
printPI       DC.B        '(A',0
printPI2      DC.B        ')+',0
printPD       DC.B        '-(A',0
printPD2      DC.B        ')',0

printComma    DC.B        ',',0
printSpace    DC.B        ' ',0
printSlash    DC.B        '/',0
printDash     DC.B        '-',0

theEnd        DC.B        CR,LF,'You are now ending the program',0

;-----------------------------------------------------------
;ERRORS
;-----------------------------------------------------------
invalCh     DC.B        'ERROR: Invalid Characters used',CR,LF,0
odd         DC.B        'ERROR: Cannot start at odd memory location',CR,LF,0
manyChar    DC.B        'ERROR: Cannot have more than 6 characters in the address',CR,LF,0
endG        DC.B        'ERROR: The ending address cannot be less than the starting address',CR,LF,0
sizeError   DC.B        'ERROR: Invalid size instruction',0
invalOpcode DC.B        'ERROR: INVALID OPCODE = ',0

            CLR.L       D3     

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
