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
            
            ;Input for the hex (D1 equals number of chars)
            MOVE.W      #2,D0
            TRAP        #15
            
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
            
            ;Reaches here if the hex number is good
            ;BRA       endingPrompt
            
            
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

    

letter:
            ;subract $31
number:
            ;subtract $30
;-----------------------------------------------------------
;MESSAGES
;-----------------------------------------------------------
Welcome     DC.B        'Welcome to the DASM by Group MULS',CR,LF,0
userSA      DC.B        'Please enter your starting address',CR,LF,0
userEA      DC.B        'Please enter your ending address',CR,LF,0

;-----------------------------------------------------------
;ERRORS
;-----------------------------------------------------------
toobig      DC.B        'ERROR: The address is too big',CR,LF,0
invalCh     DC.B        'ERROR: Invalid Characters used',CR,LF,0
odd         DC.B        'ERROR: Cannot start at odd memory location',CR,LF,0



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
