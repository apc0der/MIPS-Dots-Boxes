.data

displayAddr:	.word 0x10040000

playerScores:	.space 2

HorizontalArr:	.space 42
VerticalArr:	.space 40
BoxArr:	.space 35

GameOver: .asciiz "Game Over!\n"
ComputerWinStr: .asciiz "The computer won! :(\n \"You cannot teach a man anything, you can only help him find everything himself\""
PlayerWinStr: .asciiz "You, the player, won! :)\n \"Today's forecast, 100% chance of winning. #UnSHTOPPAble\""

# H 2 6 = 0 (no bit) 1 (horizontal) 010 (2) 110 (6)
# V 3 4 = 0 011 100 0

.eqv COLOR_WHITE			0xffffff
.eqv COLOR_PLAYER_1 			0xff0000
.eqv DOTS_START_ADDRESS_OFFSET		198964
.eqv POINT_DIFFERENCE_HORIZONTAL	200
.eqv POINT_DIFFERENCE_VERTICAL		102400

.text
.globl main BoxArr HorizontalArr VerticalArr DrawLine playerScores
main:
		lui $t0, 0xffff # Set input enable bit to 1
		ori $t1, $zero, 2 # Bit 1 in 31-0
		sw $t1, ($t0)
		li $s2, 0					# $s2 is a condition bit to end loop waiting
		li $s4, 0					# $s4 stores the current move being displayed
		lw $s0, displayAddr				# $s0 stores the base address for display, always
		li $s1, 0					# $s1 stores the player that is currently playing, 1 for AI, 0 for human
		li $s3, 0					# $s3 stores the current state of the BlinkingLine
		li $s5, 0					# $s5 and $s6 are frequently used by the AI, initialized to 0
		li $s6, 0
		li $s7, 0					# $s7 is used by the exception handler
		jal DrawGrid					# Draw the Starting Grid
		
		
	# The main gameplay loop.
	# Checks to see if the game is over, and if not, executes the lineBlinking command
	LoopBlink:
		# Checks Game Over by summing scores.
		lb $t0, playerScores
		lb $t1, playerScores + 1
		add $t2, $t1, $t0
		beq $t2, 35, Exit
		# If the player is the computer, ask it to make a move
		bnez $s1, makeMove	
		# Enter the blinking loop for the move selector
		bnez $s3, LoopUnblink
		# Activate DrawLineBlinking with a white color to show the selector
		add $a0, $zero, $s4
		addi $a1, $zero, COLOR_WHITE
		add $a2, $zero, $zero # Disable check for moveValid
	LoopUnblink:
		jal DrawLineBlinking
		addi $s2, $s2, 1
		move $s5, $zero
	# Idle loop while waiting for timer interrupt from DrawLineBlinking
	NullOps:
		addi $s5, $s5, 1
		blez $s2, LoopBlink
		j NullOps

		j Exit
			
				
# DrawGrid(int startAddress in $s0)
# Draws the grid 				
DrawGrid:	
		li $t0, POINT_DIFFERENCE_HORIZONTAL
		sll $t0, $t0, 3					# $t0 contains horizontal loop end variable (= 8 * Point Difference Horizontal)
		li $t1, POINT_DIFFERENCE_VERTICAL
		sll $t2, $t1, 2
		add $t2, $t1, $t2
		add $t1, $t1, $t2				# $t1 contains vertical loop end variable (= 6 * Point Difference Vertical)
		move $t7, $t0
		move $t8, $t1
		li $t4, COLOR_WHITE     			# color for white
		li $t5, DOTS_START_ADDRESS_OFFSET		# start addr for dots
		move $t1, $zero
		move $t2, $zero
	# Simple loop that counts 48 times for each point
	For:
		beq $t1, $t8, ForExit
		beq $t2, $t7, OuterIncrement
		add $t6, $t5, $t1
		add $t6, $t6, $t2
		add $a0, $zero, $t6
		add $a1, $zero, $t4
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal DrawPoint
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		addi $t2, $t2, POINT_DIFFERENCE_HORIZONTAL
		j For
	# Increment the loop variable by pointDifferenceVertical
	OuterIncrement:
		add $t2, $zero, $zero
		addi $t1, $t1, POINT_DIFFERENCE_VERTICAL
		j For
		
	ForExit:		
		jr $ra


# DrawPoint(int startAddress, Color color)
# Draws a point at the provided startAddress of the given Color
DrawPoint:
		add $t0, $s0, $a0
		sw $a1, 8($t0)
		sw $a1, 12($t0)
		sw $a1, 2052($t0)
		sw $a1, 2056($t0)
		sw $a1, 2060($t0)
		sw $a1, 2064($t0)
		sw $a1, 4096($t0)
		sw $a1, 4100($t0)
		sw $a1, 4104($t0)
		sw $a1, 4108($t0)
		sw $a1, 4112($t0)
		sw $a1, 4116($t0)
		sw $a1, 6144($t0)
		sw $a1, 6148($t0)
		sw $a1, 6152($t0)
		sw $a1, 6156($t0)
		sw $a1, 6160($t0)
		sw $a1, 6164($t0)
		sw $a1, 8196($t0)
		sw $a1, 8200($t0)
		sw $a1, 8204($t0)
		sw $a1, 8208($t0)
		sw $a1, 10248($t0)
		sw $a1, 10252($t0)
		
		jr $ra



# DrawSquare(byteLine line, Color c, boolean CheckSafe)
# The last bit of line (the horiz vertical bit) will not be checked.
DrawBox:
		srl $t4, $a0, 1
		srl $t3, $t4, 3
		
		addi $t0, $s0, DOTS_START_ADDRESS_OFFSET	# put the display addr into $t0
		add $t0, $t0, 12312				# go right 6 pixels (+24) and down 5 (+ 12288)			
		
	# Perform Error Checking For provided Box (bounds)
		andi $t4, $t4, 7
		bgt $t4, 4, DrawBoxError
		andi $t3, $t3, 7
		bgt $t3, 6, DrawBoxError
		
	# Time to draw the box!
	TrueDrawBox:
		mul $t3, $t3, POINT_DIFFERENCE_HORIZONTAL
		mul $t4, $t4, POINT_DIFFERENCE_VERTICAL
		add $t0, $t0, $t3
		add $t0, $t0, $t4
		lw $v0, 0($t0)					# Gets the current color of the line
		
		move $t1, $zero					# vertical loop vardd
		move $t2, $zero					# horizontal loop var
	ForDrawBox:
		beq $t1, 43, ForDrawBoxExit
		beq $t2, 43, ForDrawBoxIncrement
		sll $t3, $t1, 2
		mul $t3, $t3, 512
		sll $t4, $t2, 2
		add $t5, $t0, $t3
		add $t5, $t5, $t4
		sw $a1, 0($t5)
		addi $t2, $t2, 1
		j ForDrawBox
	ForDrawBoxIncrement:
		move $t2, $zero
		addi $t1, $t1, 1
		j ForDrawBox
	DrawBoxError:
		addi $v0, $zero, -1
	ForDrawBoxExit:	
		jr $ra
		
		
		
		
		
	DrawBoxReturn:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra


# A byteLine is defined as follows:
# Direction horizontalIndex VerticalIndex
# Ex1: H 2 3 represents the horizontal line drawn in the second row and between the third and fourth columns
# Ex2: V 6 4 represents the horizontal line drawn between the sixth row and seventh row, and in the fourth column
# In memory, we will represent a row in the following notation:
# 1) a single zero bit for padding
# 2) three bits representing the horizontal row (Take the inputted row number, subtract 1, and then write in binary)
# 3) three bits representing the vertical column (Take the inputted col number, subtract 1, and write in binary)
# 4) a single bit representing vertical vs horizontal (Vertical = 1, Horizontal = 0)
# Ex1: H 2 3 is represented as 0 001 010 0
# Ex2: V 6 4 is represented as 0 101 011 1




# DrawLine(byteLine line, Color c, boolean CheckSafe)
DrawLine:
		# Check which direction it is in and delegate to the correct method
		move $v0, $zero
		move $v1, $zero
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		andi $t0, $a0, 1
		beqz $t0, DrawHoriz
		jal DrawLineVert
		j DrawLineReturn
	DrawHoriz:
		jal DrawLineHoriz
	DrawLineReturn:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra


# DrawLineHoriz(byteLine line, Color c)
# Returns -1 if an error was encountered, or the color that was stored in the place the line was drawn.
DrawLineHoriz:
		addi $t0, $s0, DOTS_START_ADDRESS_OFFSET	# put the display addr into $t0
		add $t0, $t0, 2068				# go right 5 pixels (+20) and down 1 (+ 2048)			
		addi $t0, $t0, 4				# Move the line over by one pixel
		
	# Perform Error Checking For provided Line (bounds)
		srl $t3, $a0, 1
		andi $t4, $t3, 7
		bgt $t4, 5, DrawHorizError
		srl $t3, $t3, 3
		andi $t3, $t3, 7
		bgt $t3, 6, DrawHorizError
		
		beqz $a2, DrawLineHorizSkipCheck
	# Perform a check to see if line has already been placed

		mul $t5, $t4, 7
		add $t5, $t5, $t3
		lb $t6, HorizontalArr($t5)
		bnez $t6, DrawHorizError # If already played, don't play again
		
	# If it hasn't been played, we're set to go!
		
		addi $t6, $t6, 1
		addi $t7, $zero, 1
		sb $t6, HorizontalArr($t5)
		
		
		# Add to box values
		mul $t5, $t4, 7
		add $t5, $t5, $t3
		addi $t5, $t5, -7
		beqz $t4, SkipHorizUp
		lb $t7, BoxArr($t5)
		addi $t7, $t7, 1
		sb $t7, BoxArr($t5)
		# Afrer adding, add to player score if box = 4
		bne $t7, 4, SkipHorizUp
		sll $a0, $t4, 1
		sll $a3, $t3, 4
		add $a0, $a0, $a3
		addi $a0, $a0, -2
		addi $sp, $sp, -28
		sw $ra, 0($sp)
		sw $t5, 4($sp)
		sw $t4, 8($sp)
		sw $t3, 12($sp)
		sw $t2, 16($sp)
		sw $t1, 20($sp)
		sw $t0, 24($sp)
		jal DrawBox
		lw $t0, 24($sp)
		lw $t1, 20($sp)
		lw $t2, 16($sp)
		lw $t3, 12($sp)
		lw $t4, 8($sp)
		lw $t5, 4($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 28
		lb $t7, playerScores($s1)
		addi $t7, $t7, 1
		sb $t7, playerScores($s1)
		addi $v1, $v1, 1
				
	SkipHorizUp:
		beq $t4, 5, SkipHorizDown
		addi $t5, $t5, 7
		lb $t7, BoxArr($t5)
		addi $t7, $t7, 1
		sb $t7, BoxArr($t5)
		# Afrer adding, add to player score if box = 4
		bne $t7, 4, SkipHorizDown
		sll $a0, $t4, 1
		sll $a3, $t3, 4
		add $a0, $a0, $a3
		addi $sp, $sp, -28
		sw $ra, 0($sp)
		sw $t5, 4($sp)
		sw $t4, 8($sp)
		sw $t3, 12($sp)
		sw $t2, 16($sp)
		sw $t1, 20($sp)
		sw $t0, 24($sp)
		jal DrawBox
		lw $t0, 24($sp)
		lw $t1, 20($sp)
		lw $t2, 16($sp)
		lw $t3, 12($sp)
		lw $t4, 8($sp)
		lw $t5, 4($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 28
		lb $t7, playerScores($s1)
		addi $t7, $t7, 1
		sb $t7, playerScores($s1)
		addi $v1, $v1, 1
		
	SkipHorizDown:
		j TrueDrawLineHoriz
		
		
	DrawLineHorizSkipCheck:
		sub $s3, $t7, $s3
		add $t5, $zero, $zero
		add $t6, $zero, $zero
		
	TrueDrawLineHoriz:
		
		mul $t3, $t3, POINT_DIFFERENCE_HORIZONTAL
		mul $t4, $t4, POINT_DIFFERENCE_VERTICAL
		add $t0, $t0, $t3
		add $t0, $t0, $t4
		lw $v0, 0($t0)					# Gets the current color of the line
		
		
		
		move $t1, $zero					# vertical loop var
		move $t2, $zero					# horizontal loop var
	# Loops through a 4x44 pixel line
	ForDrawHoriz:
		beq $t1, 4, ForDrawHorizExit
		beq $t2, 44, ForDrawHorizIncrement
		sll $t3, $t1, 2
		mul $t3, $t3, 512
		sll $t4, $t2, 2
		add $t5, $t0, $t3
		add $t5, $t5, $t4
		sw $a1, 0($t5)
		addi $t2, $t2, 1
		j ForDrawHoriz
	ForDrawHorizIncrement:
		move $t2, $zero
		addi $t1, $t1, 1
		j ForDrawHoriz
	DrawHorizError:
		addi $v0, $zero, -1
	ForDrawHorizExit:	
		jr $ra
		

# DrawLineVert(byteLine line, Color c)
# Returns -1 if an error was encountered, or the color that was stored in the place the line was drawn.
DrawLineVert:
		move $v1, $zero
		add $v0, $zero, $zero
		addi $t0, $s0, DOTS_START_ADDRESS_OFFSET	# put the display addr into $t0
		addi $t1, $zero, 2048
		
		
		sll $t2, $t1, 2
		add $t2, $t1, $t2
		add $t1, $t1, $t2				# place 6 vertical pixels into $t1
		add $t0, $t0, $t1				# Start address for the line
		addi $t0, $t0, 4				# Move the line over by one pixel
		
		# Bounds Error Checking
		srl $t3, $a0, 1
		andi $t4, $t3, 7
		bgt $t4, 4, DrawVertError
		srl $t3, $t3, 3
		andi $t3, $t3, 7
		bgt $t3, 7, DrawVertError
		
		beqz $a2, DrawLineVertSkipCheck
		
		# Perform a check to see if line has already been placed
		mul $t5, $t4, 8
		add $t5, $t5, $t3
		lb $t6, VerticalArr($t5)
		bnez $t6, DrawVertError # If already played, don't play again
		
		# If it hasn't been played, we're set to go!
		addi $t6, $t6, 1
		addi $t7, $zero, 1
		sb $t6, VerticalArr($t5)
		
		# Add to box values
		mul $t5, $t4, 7
		add $t5, $t5, $t3
		addi $t5, $t5, -1
		beqz $t3, SkipVertLeft
		lb $t7, BoxArr($t5)
		addi $t7, $t7, 1
		sb $t7, BoxArr($t5)
		
		# Afrer adding, add to player score if box = 4
		bne $t7, 4, SkipVertLeft
		sll $a0, $t4, 1
		sll $a3, $t3, 4
		add $a0, $a0, $a3
		addi $a0, $a0, -16
		addi $sp, $sp, -28
		sw $ra, 0($sp)
		sw $t5, 4($sp)
		sw $t4, 8($sp)
		sw $t3, 12($sp)
		sw $t2, 16($sp)
		sw $t1, 20($sp)
		sw $t0, 24($sp)
		jal DrawBox
		lw $t0, 24($sp)
		lw $t1, 20($sp)
		lw $t2, 16($sp)
		lw $t3, 12($sp)
		lw $t4, 8($sp)
		lw $t5, 4($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 28
		lb $t7, playerScores($s1)
		addi $t7, $t7, 1
		sb $t7, playerScores($s1)
		addi $v1, $v1, 1
		
		
		
	SkipVertLeft:
		beq $t3, 7 SkipVertRight
		addi $t5, $t5, 1
		lb $t7, BoxArr($t5)
		addi $t7, $t7, 1
		sb $t7, BoxArr($t5)
		
		# Afrer adding, add to player score if box = 4
		bne $t7, 4, SkipVertRight
		sll $a0, $t4, 1
		sll $a3, $t3, 4
		add $a0, $a0, $a3
		addi $sp, $sp, -28
		sw $ra, 0($sp)
		sw $t5, 4($sp)
		sw $t4, 8($sp)
		sw $t3, 12($sp)
		sw $t2, 16($sp)
		sw $t1, 20($sp)
		sw $t0, 24($sp)
		jal DrawBox
		lw $t0, 24($sp)
		lw $t1, 20($sp)
		lw $t2, 16($sp)
		lw $t3, 12($sp)
		lw $t4, 8($sp)
		lw $t5, 4($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 28
		lb $t7, playerScores($s1)
		addi $t7, $t7, 1
		sb $t7, playerScores($s1)
		addi $v1, $v1, 1
	SkipVertRight:
		j TrueDrawLineVert
		
	DrawLineVertSkipCheck:
		sub $s3, $t7, $s3
		add $t5, $zero, $zero
		add $t6, $zero, $zero
		
	TrueDrawLineVert:
		mul $t3, $t3, POINT_DIFFERENCE_HORIZONTAL
		mul $t4, $t4, POINT_DIFFERENCE_VERTICAL
		add $t0, $t0, $t3
		add $t0, $t0, $t4
		lw $v0, 0($t0)					# Gets the current color of the line
		
		move $t1, $zero					# vertical loop var
		move $t2, $zero					# horizontal loop var
	ForDrawVert:
		beq $t1, 44, ForDrawVertExit
		beq $t2, 4, ForDrawVertIncrement
		sll $t3, $t1, 2
		mul $t3, $t3, 512
		sll $t4, $t2, 2
		add $t5, $t0, $t3
		add $t5, $t5, $t4
		sw $a1, 0($t5)
		addi $t2, $t2, 1
		j ForDrawVert
	ForDrawVertIncrement:
		move $t2, $zero
		addi $t1, $t1, 1
		j ForDrawVert
	DrawVertError:
		addi $v0, $zero, -1
	ForDrawVertExit:		
		jr $ra
	
# DrawLineBlinking(byteLine line, Color c)
# Draws the line given in the given color, then reverts it to the prior color using a timer interrupt for 500ms.
DrawLineBlinking:
		# Checks if it is reverting or drawing
		bnez $s3, DrawLineBlinkingReturn
		# Checks if a new color was loaded
		beqz $t9, ColorSetSkip
		move $a0, $t8
		move $a1, $t9
		
	ColorSetSkip:
	# Draw the line
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal DrawLine
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
	# Set the color values
		move $t8, $a0
		move $t9, $v0
		addi $s3, $zero, 1
		
	# Add a timer interrupt 500ms in the future
		li $a0, 500
		la $a1, DrawLineBlinking
		li $v0, 37
		syscall
		
	# Exit with a success code
		li $v0, 1
		jr $ra
		
	DrawLineBlinkingReturn:
	# On the flip side, we are reverting the color, restore the og color!
		move $a0, $t8
		move $a1, $t9
		
	# Undraw the line
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jal DrawLine
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
	# Store the changed colors
		move $t8, $a0
		move $t9, $v0
		add $s3, $zero, $zero
		
	# Add timer interrupt
		li $a0, 500
		la $a1, DrawLineBlinking
		li $v0, 37
		syscall
		
	# Return!				
		move $v0, $zero
		jr $ra
	

Return:
		move $v0, $zero
		jr $ra
	
Exit:
	# Check who wins and give them their dub
		bgt $t1, $t0, ComputerWin
		
		li $v0, 59
		la $a0, GameOver
		la $a1, PlayerWinStr
		syscall
		j done
		
	ComputerWin:
		li $v0, 59
		la $a0, GameOver
		la $a1, ComputerWinStr
		syscall
		
	done:
		li $v0, 10 # terminate the program gracefully
		syscall
