.kdata
IHstore:	.space 12 	# Space for three registers to be freed up
non_intrpt_str: .asciiz "Non-interrupt exception\n"
unhandled_str: .asciiz "Unhandled interrupt type\n"
DrawLine: .word 0x0040022c
DrawLineBlinking: .word 0x004006ec

jumpTable:
	#.word 0x

.eqv COLOR_PLAYER_1 			0xff0000
.eqv COLOR_PLAYER_COMPUTER 		0x0000ff

.ktext 0x80000180

interrupt_handler:
		move $k1, $at # Save $at
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		
		la $k0, IHstore
		sw $a0, 0($k0) # Get some free registers
		sw $a1, 4($k0) # by storing them to a global variable
		sw $v0, 8($k0)
		mfc0 $k0, $13 # Get Cause register
		srl $a0, $k0, 2
		and $a0, $a0, 0xf # ExcCode field
		bne $a0, 0, non_intrpt
		j interrupt_dispatch
		
interrupt_dispatch: # Interrupt:
		mfc0 $k0, $13 # Get Cause register, again
		beq $k0, $zero, done # handled all outstanding interrupts
		and $a0, $k0, 0x100 # Detects MMIO Interrupt
		bne $a0, 0, MMIO_interrupt
		and $a0, $k0, 0x8000 # is there a timer interrupt?
		bne $a0, 0, timer_interrupt
	# add dispatch for other interrupt types here.
	
		li $v0, 4 # Unhandled interrupt types
		la $a0, unhandled_str
		syscall
		j done
		
MMIO_interrupt:
		lb $v1, 0xffff0004($zero)
		beq $v1, 32, Space
		beq $v1, 119, W
		beq $v1, 97, A
		beq $v1, 115, S
		beq $v1, 100, D
		beq $v1, 10, Enter
		j MMIO_complete
	Space:
		# Checks if moving with W is valid
		andi $k1, $s4, 1
		beqz $k1, CheckSpaceHorizontal
	CheckSpaceVertical:
		srl $k0, $s4, 4
		andi $k0, $k0, 7
		bge $k0, 7, MMIO_complete
		j SpaceContinue
	
	CheckSpaceHorizontal:
		srl $k0, $s4, 1
		andi $k0, $k0, 7
		bge $k0, 5, MMIO_complete
		
	SpaceContinue:
		# Implement bounds checking. (When byteLine is at bottom, cannot flip to vertical, when at right, cannot flip to horizontal)
		jal MMIO_Check
		xori $s4, $s4, 1 #Flip last bit (all other remain untouched)
		j MMIO_complete
	W:
		# Checks if moving with W is valid
		srl $k0, $s4, 1	
		andi $k0, $k0, 7 # Get just the vertical component of the line.
		beqz $k0, MMIO_complete	# If vert comp = 0, just exit
	
		# Perform the movement
		jal MMIO_Check
		addi $s4, $s4, -2 # Subtracts 1 from the vertical portion of the line
		j MMIO_complete
	A:
		# Checks if moving with A is valid
		srl $k0, $s4, 4
		andi $k0, $k0, 7 # Get just the horizontal compoent of the line
		blez $k0, MMIO_complete	# If horizontal comp = 0, just exit
		
		# Perform the movement
		jal MMIO_Check
		addi $s4, $s4, -16 # Subtracts 1 from the horizontal portion of the line
		j MMIO_complete
	S:
		# Checks if moving with S is valid
		andi $k1, $s4, 1
		xori $k1, $k1, 1
		srl $k0, $s4, 1
		andi $k0, $k0, 7 # Get just the vertical compoent of the line
		addi $k1, $k1, 4
		bge $k0, $k1, MMIO_complete # If vertical comp > (horizline)?5:4 , just exit
	
		# Perform the movement
		jal MMIO_Check
		addi $s4, $s4, 2 # Adds 1 to the vertical portion of the line
		j MMIO_complete
	D:
		# Checks if moving with D is valid
		andi $k1, $s4, 1
		srl $k0, $s4, 4
		andi $k0, $k0, 7 # Get just the horizontal compoent of the line
		addi $k1, $k1, 6
		bge $k0, $k1, MMIO_complete # If horizontal comp > (horizline)?6:7 , just exit
	
		# Perform the movement
		jal MMIO_Check
		addi $s4, $s4, 16 # Subtracts 1 from the vertical portion of the line
		j MMIO_complete
	Enter:
		jal MMIO_Check
		bnez $s1, MMIO_complete
		li $s7, 0x7fffffff		# Stop blinking
		mtc0 $s7, $11
		move $a0, $s4
		addi $a1, $zero, COLOR_PLAYER_1
		addi $a2, $zero, 1	# Enable check for valid move
		
		lw $s7, DrawLine($zero)
		jalr $s7
		
		# TODO: Disable blinking for 3 seconds
		add $a2, $zero, $zero
		li $s2, -1
		
		bnez $v0, SkipChangePlayer
		bnez $v1, SkipChangePlayer
		li $s1, 1
	SkipChangePlayer:
		# addi $s1, $s1, 1
		j MMIO_complete
	
	MMIO_Check:
		li $s7, 0x7fffffff
		mtc0 $s7, $11
		beqz $s3, MMIO_CheckComplete
		lw $s7, DrawLineBlinking($zero)
		
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		jalr $s7
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		move $t9, $zero
		li $s7, 0x7fffffff
		mtc0 $s7, $11
		move $s2, $zero
		move $s3, $zero
		jr $ra
	MMIO_CheckComplete:
		move $t9, $zero		# Reset current stored line in blinkingLine
		move $s2, $zero
		move $s3, $zero
		jr $ra
		
	
	MMIO_complete:
		j done # end this.
		
timer_interrupt:
	# Add a way for us to store $a0 $a1 through other assembler calls, like providing more space. That way, We can
	# unDraw ONLY lines that have been drawn
		lw $k0, 0xffff0010($zero)
		jalr $k0
		j done
		
non_intrpt: # was some non-interrupt
		li $v0, 4
		la $a0, non_intrpt_str
		syscall # print out an error message
		j done
		
done:
		la $k0, IHstore
		lw $v0, 8($k0)
	
		la $k0, IHstore
		lw $a0, 0($k0) # Restore used Registers	
		lw $a1, 4($k0) # ...
		move $at, $k1 # Restore $at
		
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
eret:
		eret # Return from exception handler
