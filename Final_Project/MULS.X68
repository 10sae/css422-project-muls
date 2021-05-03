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
            
            MOVE.W      0, A1
            
            ;Input for the hex (D1 equals number of chars)
            MOVE.W      #2,D0
            TRAP        #15
            
            MOVEA.L     A1,A2
                   
            ;Check to see if D1 is greater than 6, limiting the address to 6 characters (subject to change)
            CMP.B       #6, D1
            BGT         manyCharError  
            
convert:    
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
            
            ;Move the actual hex value into our variable
            MOVE.L      D6,staHex
            
            ;Copy the hex value into a temp register
            MOVE.L      (A2),D4
            
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
            MOVE.W      0,A2
            
            
            ;Reaches here if the hex number is good
            BRA       endingPrompt
            
            
endingPrompt:
            
            ;Ask the user for the ending hex
            LEA         userEA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Input for the hex (D1 equals number of chars)
            MOVE.W      #14,D0
            TRAP        #15
            
            MOVE.W      D1,endHex
            
            ;Place one character on a stack, if end of stack, then go to endingPrompt
            ;   if between $41 and $46 [included] (Meaning the character is a letter)
            ;        BRA    letter
            ;
            ;   if between $30 and $39 [included] (Meaning the character is a number)
            ;        BRA    number
            ;
            ;   Else, the characters is a special one, 
            ;        return error
            ;        BRA    startingPrompt
            ;
            ;Loop byte-by-byte through the hex until the end (Right-most digit)
            
            ;Move the converted hex into staHex
            
            ;Compare the ending address w/ starting
            ;if endAdd is less than staAdd
            ;    return error
            ;    BRA    endingPrompt
    
            ;A42A
            ;0000 0000 0000 0000 1010 0100 0010 1010
            ;shift left 28 (1010 0000.....)
            ;shift right 28 times (0000..... 1010)
            ;compare 1,3,5,7,9,B,D,F with A
            ;if even continue work
            ;if odd
            ;   return error
            ;   BRA startingPrompt

            ;If more than 8 bytes
            ;      return error
            ;      BRA      startingPrompt
            ;

    

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
            MOVE.B      #14, D0
            TRAP        #15
            
            BRA         startingPrompt
            
            
;-----------------------------------------------------------
;MESSAGES
;-----------------------------------------------------------
Welcome     DC.B        'Welcome to the DASM by Group MULS',CR,LF,0
userSA      DC.B        'Please enter your starting hex address (Only uppercase letters)',CR,LF,0
userEA      DC.B        'Please enter your ending hex address (Only uppercase letters)',CR,LF,0

;-----------------------------------------------------------
;ERRORS
;-----------------------------------------------------------
toobig      DC.B        'ERROR: The address is too big',CR,LF,0
invalCh     DC.B        'ERROR: Invalid Characters used',CR,LF,0
odd         DC.B        'ERROR: Cannot start at odd memory location',CR,LF,0
manyChar    DC.B        'ERROR: Cannot have more than 6 characters in the address',CR,LF,0



*-----------------------------------------------------------
* OpCode Implementation
*-----------------------------------------------------------
*-----------------------------------------------------------
* Addressing Mode Implementation
*-----------------------------------------------------------

    END    MAIN 


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
