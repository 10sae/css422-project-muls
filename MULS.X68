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
            
            ;Input for the hex
            MOVE.L      #2,D0
            TRAP        #15
            
            MOVE.L      D1,staHex
            
            ;Check for errors
            ;If error occurred, loop back to startingPrompt
            ;BEQ         startingPrompt
            
endingPrompt:
            
            ;Ask the user for the ending hex
            LEA         userEA,A1
            MOVE.B      #14,D0
            TRAP        #15
            
            ;Input for the hex
            MOVE.L      #14,D0
            TRAP        #15
            
            MOVE.L      D1,endHex
            
    
            ;Check for errors
            ;If error occurred, loop back to endingPrompt
            ;BEQ        endingPrompt

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
