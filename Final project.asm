;*****************************************************************************
; Author: Michael J Habermann
; Date: 4/30/2023
; Revision: 1.0
;
; Description:
; A tic tac toe program made in LC-3. Using registers, flipping bits to make a number negative, and subroutines
;
; Register Usage:
; R0 Used mainly for outputing to console but also the win check
; R1 used for the loop in the main function
; R2 Used in the loop for displayBoard and some offsets
; R3 Used to check if a space on the board is available
; R4 Holds the message on whos turn it is
; R5 Holds the letter of whos turn it is either X or O
; R6 Used to hold the stacks memory address
; R7 Holds the return address of the subroutines
;****************************************************************************/
.orig x3000
	JSR INIT
	JSR displayBoard
	LD R5, p1turnchar
	LEA R4, p1TurnMessage
	JSR playerTurn
	JSR displayBoard
	AND R1, R1, #0
	ADD R1, R1, #4
loop2;Repeats the function cutting down on some lines of code
	LEA R4, p2TurnMessage
	LD R5, p2turnchar
	JSR playerTurn
	JSR displayBoard
	LEA R4, p1TurnMessage
	LD R5, p1turnchar
	JSR playerTurn
	JSR displayBoard
ADD R1, R1, #-1
brnp loop2
	LEA R0, tie
	trap x22
halt
;************************INIT**********************************
;An initilization subroutine for the program including resetting the board
;
;R0 - Used for outputing characters and strings
;R1 - Used to load the board with empty spaces
;R6 - Used to hold the stacks memory address
;***************************************************************
INIT
    LD r6, characterStorage
    LD r0, emptySpace
    AND R1,R1, #0
    ADD R1, R1, #9
resetBoard;Loads the stack with ASCII #20 which is a whitespace
    STR R0, R6, #0
    ADD R6,R6, #1
    ADD R1,R1, #-1
    BRp resetBoard
ret
;************************displayBoard***************************
;This subroutine stores the input of a string from the user
;
;R0 - Used for outputing characters and strings
;R2 - Used for looping the board cutting down on repeated code
;R6 - Used to hold the stacks memory address
;R7 - return address from subroutine
;***************************************************************
displayBoard
    ST R7, SaveR7
	AND R2, R2, #0
	ADD R2, R2, #3
    LD r6, characterStorage
loop;Repeats the function cutting down on some lines of code
    LDR r0, r6, #0
    trap x21
    LEA R0, col
    trap x22
    ADD r6, R6,#1
    LDR r0, r6, #0
    trap x21
    LEA R0, col
    trap x22
    ADD r6, R6,#1
    LDR r0, r6, #0
    trap x21
    LD R0, nullTerminator
    trap x21
    LEA r0, row
    trap x22
    LD R0, nullTerminator
    trap x21
	ADD R6, R6, #1
	ADD R2, R2, #-1
	brnp loop
    LD R7, SaveR7
ret
;************************playerTurn**********************************
;This handles the players turn. Taking input and saving it to the stack if its valid
;
;R0 - reserve for TRAP
;R2 - Holds the ASCII offset value
;R3 - Used to check if a space on the board is available
;R4 - Holds the output of either player 1 or player2
;R5 - Holds the letter of whos turn it is either X or O
;R6 - Used to hold the stacks memory address
;R7 - return address from subroutine
;***************************************************************
playerTurn
	ST  R7, SaveR7
p1TurnReDo;If the turn is invalid it will repeat the turn
	AND R3, R3, #0
	LD R6, characterStorage
	LD R2, ASCIIoffset
	AND R0, R0, #0
	ADD R0, R4, #0
	trap x22
	LEA R0, turnMessage
	trap x22
	trap x20
	trap x21
	ADD R3, R0, R2
	LD R0, nullTerminator
    trap x21
	ADD R6, R6, R3
	LDR R3, R6, #0
	LD R2, spaceCheckNum
	ADD R3, R3, R2
	BRnp p1TurnReDo;if turn is invalid repeat loop else place player icon
	STR R5, R6, #0
    LD R7, SaveR7
	JSR playerWinCheck;Checks for if the current player placed down a winning move
	LD R7, SaveR7
ret
;************************playerWinCheck*************************
;Checks for if the current player placed down a winning move
;
;R0 - reserve for TRAP
;R2 - The length of the message taken from previous subroutine
;R4 - Holds the address of where the message will be stored
;R5 - Holds the test for ASCII being lowercase
;R7 - return address from subroutine
;***************************************************************
playerWinCheck
Row1check;Checks the top row for 3 in a row
	NOT R5, R5
	ADD R5, R5, #1
	LD R6, characterStorage
	LDR R0, R6, #0
	ADD R0, R0, R5
	brnp Row2check
	LDR R0, R6, #1
	ADD R0, R0, R5
	brnp Row2check
	LDR R0, R6, #2
	ADD R0, R0, R5
	brnp Row2check
	brnzp whoWon
Row2check;Checks the middle row for 3 in a row
	LDR R0, R6, #3
	ADD R0, R0, R5
	brnp Row3check
	LDR R0, R6, #4
	ADD R0, R0, R5
	brnp Row3check
	LDR R0, R6, #5
	ADD R0, R0, R5
	brnp Row3check
	brnzp whoWon
Row3check;Checks the bottom row for 3 in a row
	LDR R0, R6, #6
	ADD R0, R0, R5
	brnp Col1check
	LDR R0, R6, #7
	ADD R0, R0, R5
	brnp Col1check
	LDR R0, R6, #8
	ADD R0, R0, R5
	brnp Col1check
	brnzp whoWon
Col1check;Checks the left column for 3 in a row
	LDR R0, R6, #0
	ADD R0, R0, R5
	brnp Col2check
	LDR R0, R6, #3
	ADD R0, R0, R5
	brnp Col2check
	LDR R0, R6, #6
	ADD R0, R0, R5
	brnp Col2check
	brnzp whoWon
Col2check;Checks the middle column for 3 in a row
	LDR R0, R6, #1
	ADD R0, R0, R5
	brnp Col3check
	LDR R0, R6, #4
	ADD R0, R0, R5
	brnp Col3check
	LDR R0, R6, #7
	ADD R0, R0, R5
	brnp Col3check
	brnzp whoWon
Col3check;Checks the right column for 3 in a row
	LDR R0, R6, #2
	ADD R0, R0, R5
	brnp Vert1check
	LDR R0, R6, #5
	ADD R0, R0, R5
	brnp Vert1check
	LDR R0, R6, #8
	ADD R0, R0, R5
	brnp Vert1check
	brnzp whoWon
Vert1check;Checks the left cross for 3 in a row
	LDR R0, R6, #0
	ADD R0, R0, R5
	brnp Vert2check
	LDR R0, R6, #4
	ADD R0, R0, R5
	brnp Vert2check
	LDR R0, R6, #8
	ADD R0, R0, R5
	brnp Vert2check
	brnzp whoWon
Vert2check;Checks the right cross for 3 in a row
	LDR R0, R6, #2
	ADD R0, R0, R5
	brnp nullWinner
	LDR R0, R6, #4
	ADD R0, R0, R5
	brnp nullWinner
	LDR R0, R6, #6
	ADD R0, R0, R5
	brnp nullWinner
	brnzp whoWon
nullWinner;If we ended up here there is no winner(yet)
ret

whoWon;Checks who won based on whos turn it is
	LD R1, p1turnchar
	ADD R1, R1, R5
	brz p1Winner
	LD R1, p2turnchar
	ADD R1, R1, R5
	brz p2Winner

p1Winner;If player 1 got 3 X's in a row they won
	JSR displayBoard
	LEA R0, p1WinnerMessage
	trap x22
halt
p2Winner;If player 2 got 3 O's in a row they won
	JSR displayBoard
	LEA R0, p2WinnerMessage
	trap x22
halt

p1Negation .fill xFFA8
SaveR7 .fill x0000
tie .Stringz "It's a tie better luck next time\n"
emptySpace .fill x20
spaceCheckNum .fill xFFE0
nullTerminator .fill #10
characterStorage .fill x2FF7
ASCIIoffset .fill xFFCF
p1turnchar .fill x58
p2turnchar .fill x4F
p1TurnMessage .stringz "Player 1 "
p2TurnMessage .stringz "Player 2 "
turnMessage .stringz "enter a Number between 1-9: "
col .stringz " | "
row .Stringz "----------"
p1WinnerMessage .stringz "Player 1 is the Winner!!!!\n"
p2WinnerMessage .stringz "Player 2 is the Winner!!!!\n"
p2Negation .fill xFFB1
.end