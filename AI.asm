.data
S5: .word 0
S6: .word 0

.eqv COLOR_PLAYER_COMPUTER 		0x0000ff
.text
.globl makeMove
makeMove:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		sw $s5, S5($zero)
		sw $s6, S6($zero)
		
		jal takeSafe3s # greedily takes all 3s that if taken, will not form a 2
		
#		move $s5, $zero
#		move $s6, $zero
#		jal sides3
#		move $s5, $v0
#		beqz $v1, makeMoveBIGElseIf
#	IfSides01:
#		jal sides01
#		move $s6, $v0
#		beqz $v1, makeMoveSacrifice
#		jal takeall3s
#		move $a0, $s6
#		jal takeEdge
#		j makeMoveDone
		
		
	makeMoveSacrifice:
#		move $a0, $v0
#		j makeMoveDone
	
	
	
	# sides 01, singleton, doubleton, any
	makeMoveBIGElseIf:
#		jal sides01
#		beqz $v1, makeMoveSingletonElif
#		move $a0, $v0
#		jal takeEdge
#		j makeMoveDone
		
	makeMoveSingletonElif:
#		jal singleton
#		beqz $v1, makeMoveDoubletonElif
	
	makeMoveDoubletonElif:
#		jal doubleton
#		beqz $v1, makeMoveAnyElse
	
	makeMoveAnyElse:
		jal makeAnyMove
		move $a0, $v0
		li $v0, 1
		syscall
		jal takeEdge
	
	makeMoveDone:
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	
    	lw $s5, S5($zero)
	lw $s6, S6($zero)
		
    	move $s1, $zero
    	jr $ra
    
takeSafe3s:
	addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $t0, 4($sp)
		sw $t1, 8($sp)
		sw $t2, 12($sp)
		sw $t3, 16($sp)
		sw $t4, 20($sp)
		sw $t5, 24($sp)
		sw $t6, 28($sp)
		sw $t7, 32($sp)
	li $s5, 0
	li $s6, 0
	ts3loop1: 
	beq $s5, 5, ts3exit
	ts3loop2:
	beq $s6, 7, ts3exit1
	move $t0, $s5
	mul $t0, $t0, 7
	add $t0, $t0, $s6
	lb $t1, BoxArr($t0)
	bne $t1, 3, ts3exit2
        move $t0, $s5
        mul $t0, $t0, 8
        add $t0, $t0, $s6
        lb $t2, VerticalArr($t0)
        bne $t2, 0, cond2
        
            bnez $s6, checkNextBox
            sll $a0, $s5, 1
            sll $a1, $s6, 4
            add $a0, $a0, $a1
            addi $a0, $a0, 1
            li $a1, COLOR_PLAYER_COMPUTER
            li $a2, 1
            jal DrawLine
            j ts3exit2
            
        checkNextBox:
		move $t0, $s5
		mul $t0, $t0, 7
		add $t0, $t0, $s6
        addi $t0, $t0, -1
            lb $t3, BoxArr($t0)
            beq $t3, 2, cond2
            # setVedge(i, j)
            sll $a0, $s5, 1
            sll $a1, $s6, 4
            add $a0, $a0, $a1
            addi $a0, $a0, 1
            li $a1, COLOR_PLAYER_COMPUTER
            li $a2, 1
            jal DrawLine
            j ts3exit2
            
        cond2:
        move $t0, $s5
        mul $t0, $t0, 7
        add $t0, $t0, $s6
        lb $t2, HorizontalArr($t0)
        bne $t2, 0, cond3
            bnez $s6, checkNextBox2
            sll $a0, $s5, 1
            sll $a1, $s6, 4
            add $a0, $a0, $a1
            li $a1, COLOR_PLAYER_COMPUTER
            li $a2, 1
            jal DrawLine
            j ts3exit2
            
        checkNextBox2:
        addi $t0, $t0, -7
            lb $t3, BoxArr($t0)
            beq $t3, 2, cond3
            # setVedge(i, j)
            sll $a0, $s5, 1
            sll $a1, $s6, 4
            add $a0, $a0, $a1
            li $a1, COLOR_PLAYER_COMPUTER
            li $a2, 1
            jal DrawLine
            j ts3exit2

        cond3: 
        move $t0, $s5
        mul $t0, $t0, 8
        add $t0, $t0, $s6
        addi $t0, $t0, 1
        lb $t2, VerticalArr($t0)
        bne $t2, 0, cond4
            bne $s6, 6, checkNextBox3
            sll $a0, $s5, 1
            sll $a1, $s6, 4
            add $a0, $a0, $a1
            addi $a0, $a0, 16
            addi $a0, $a0, 1
            li $a1, COLOR_PLAYER_COMPUTER
            li $a2, 1
            jal DrawLine
            j ts3exit2
            
        checkNextBox3:
            move $t0, $s5
        mul $t0, $t0, 7
        add $t0, $t0, $s6
        addi $t0, $t0, 1
            lb $t3, BoxArr($t0)
            beq $t3, 2, cond4
            # setVedge(i, j)
            sll $a0, $s5, 1
            sll $a1, $s6, 4
            add $a0, $a0, $a1
            addi $a0, $a0, 16
            addi $a0, $a0, 1
            li $a1, COLOR_PLAYER_COMPUTER
            li $a2, 1
            jal DrawLine
            j ts3exit2
        

        cond4: 
        move $t0, $s5
        mul $t0, $t0, 7
        add $t0, $t0, $s6
        addi $t0, $t0, 7
        lb $t2, HorizontalArr($t0)
        bne $t2, 0, ts3exit2
            bne $s5, 4, checkNextBox4
            sll $a0, $s5, 1
            sll $a1, $s6, 4
            add $a0, $a0, $a1
            addi $a0, $a0, 2
            li $a1, COLOR_PLAYER_COMPUTER
            li $a2, 1
            jal DrawLine
            j ts3exit2
            
        checkNextBox4:
            move $t0, $s5
        mul $t0, $t0, 7
        add $t0, $t0, $s6
        addi $t0, $t0, 7
            lb $t3, BoxArr($t0)
            beq $t3, 2, ts3exit2
            # setVedge(i, j)
            sll $a0, $s5, 1
            sll $a1, $s6, 4
            add $a0, $a0, $a1
            addi $a0, $a0, 2
            li $a1, COLOR_PLAYER_COMPUTER
            li $a2, 1
            jal DrawLine
            j ts3exit2

    ts3exit2:       
    addi $s6, $s6, 1
    j ts3loop2
    ts3exit1:
    add $s6, $zero, $zero
    addi $s5, $s5, 1
    j ts3loop1
ts3exit:
    lw $ra, 0($sp)
		lw $t0, 4($sp)
		lw $t1, 8($sp)
		lw $t2, 12($sp)
		lw $t3, 16($sp)
		lw $t4, 20($sp)
		lw $t5, 24($sp)
		lw $t6, 28($sp)
		lw $t7, 32($sp)
		addi $sp, $sp, 36
		jr $ra


sides3:
	addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $t0, 4($sp)
		sw $t1, 8($sp)
		sw $t2, 12($sp)
		sw $t3, 16($sp)
		sw $t4, 20($sp)
		sw $t5, 24($sp)
		sw $t6, 28($sp)
		sw $t7, 32($sp)
    li $s5, 0
    li $s6, 0
    li $v0, 0
    li $v1, 0
    # For every box, 
    s3loop1: 
    beq $s5, 5, s3exit
    s3loop2:
    beq $s6, 7, s3exit1
    move $t0, $s5
    mul $t0, $t0, 7
    add $t0, $t0, $s6
    lb $t1, BoxArr($t0)
    bne $t1, 3, s3exit2
        sll $t1, $s5, 1
        sll $t2, $s6, 4
        add $t2, $t2, $t1
        move $v0, $t2
        li $v1, 1
        j s3exit
    s3exit2:
    addi $s6, $s6, 1
    j s3loop2
    
    s3exit1:
    move $s6, $zero
    addi $s5, $s5, 1
    j s3loop1
s3exit: 
lw $ra, 0($sp)
		lw $t0, 4($sp)
		lw $t1, 8($sp)
		lw $t2, 12($sp)
		lw $t3, 16($sp)
		lw $t4, 20($sp)
		lw $t5, 24($sp)
		lw $t6, 28($sp)
		lw $t7, 32($sp)
		addi $sp, $sp, 36
		jr $ra

	
takeall3s:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
    ta3w:
    
    jal sides3 # puts t/f in $v1, box in $v0
    beqz $v1, ta3exit # if false, exit
    	move $a0, $v0
        jal takebox # takebox method
        j ta3w # restart loop
ta3exit:

	lw $ra, 0($sp)
    	addi $sp, $sp, 4
	jr $ra # jump back




takebox:
	addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $t0, 4($sp)
		sw $t1, 8($sp)
		sw $t2, 12($sp)
		sw $t3, 16($sp)
		sw $t4, 20($sp)
		sw $t5, 24($sp)
		sw $t6, 28($sp)
		sw $t7, 32($sp)
    srl $t4, $a0, 1  # move u into temp
    andi $t4, $t4, 7
    srl $t5, $a0, 4 # move v into temp
    mul $t6, $t5, 7 # u *= 7
    add $t6, $t6, $t4 # u += v
    lb $t7, HorizontalArr($t6) # move byte into $t6
    bnez $t7, tbc2 # if already 1, go to next cond
        # setHedge(i, j) 7*u+v
        li $a1, COLOR_PLAYER_COMPUTER
        li $a2, 1
        jal DrawLine
        j tbexit
    tbc2:
    mul $t6, $t4, 8 # u *= 8
    add $t6, $t6, $t5 # u += v
    lb $t7, VerticalArr($t6) # move byte into $t6
    bnez $t7, tbc3
        # setVedge($t6) <- 8*u+v
        addi $a0, $a0, 1
        li $a1, COLOR_PLAYER_COMPUTER
        li $a2, 1
        jal DrawLine
        j tbexit
    tbc3:
    mul $t6, $t4, 7
    add $t6, $t6, $t5
    addi $t6, $t6, 7
    lb $t7, HorizontalArr($t6)
    bnez $t7, tbc4
        # setHedge($t6) <- 7*(u+1)+v
        addi $a0, $a0, 1
        li $a1, COLOR_PLAYER_COMPUTER
        li $a2, 16
        jal DrawLine
        j tbexit
    tbc4:
    mul $t4, $t4, 7
    add $t6, $t6, $t5
    addi $t6, $t6, 1
    lb $t7, HorizontalArr($t6)
    	# setVedge($t6) <- 8*u+v+1
    	addi $a0, $a0, 1
        li $a1, COLOR_PLAYER_COMPUTER
        li $a2, 3
        jal DrawLine
tbexit:
	lw $ra, 0($sp)
		lw $t0, 4($sp)
		lw $t1, 8($sp)
		lw $t2, 12($sp)
		lw $t3, 16($sp)
		lw $t4, 20($sp)
		lw $t5, 24($sp)
		lw $t6, 28($sp)
		lw $t7, 32($sp)
		addi $sp, $sp, 36
		jr $ra


safehedge:
    move $t6, $a1 # move i into temp
    move $t7, $a2 # move j into temp
    mul $t6, $t6, 7
    add $t6, $t6, $t7 # 7 * i + j
    lb $a3, HorizontalArr($t6)
    bnez $a3, shexit # if not zero , false
        bnez $a1, shc2 # if not zero, go to next condition
            lb $a3, BoxArr($t6) # [i][j]
            blt $a3, 2, shtrue  # if 0 or 1, true
            j shexit # else, false
        shc2:
        bne $a1, 5, shc3
            add $t6, $t6, -7 
            lb $a3, BoxArr($t6) # [i-1][j]
            blt $a3, 2, shtrue
            j shexit
        shc3:
            lb $a3, BoxArr($t6) # AND: if first fails, exit, then if second fails, exit
            bgt $a3, 1, shexit 
            add $t6, $t6, -7
            lb $a3, BoxArr($t6)
            bgt $a3, 1, shexit
            j shtrue # otherwise, true!
shtrue:
li $v1, 1
jr $ra
shexit:
li $v1, 0
jr $ra

safevedge: # just like above method
    move $t6, $a1 # move i into temp
    move $t7, $a2 # move j into temp
    mul $t6, $t6, 8
    add $t6, $t6, $t7
    lb $a3, VerticalArr($t6)
    bnez $a3, svexit
        bnez $a2, svc2
            lb $a3, BoxArr($t6) # [i][j]
            blt $a3, 2, svtrue
            j svexit
        svc2:
        bne $a1, 7, svc3
            add $t6, $t6, -1
            lb $a3, BoxArr($t6) #[i][j-1]
            blt $a3, 2, svtrue
            j svexit
        svc3:
            lb $a3, BoxArr($t6)
            bgt $a3, 1, svexit
            add $t6, $t6, -1
            lb $a3, BoxArr($t6)
            bgt $a3, 1, svexit
            j svtrue
svtrue:
li $v1, 1
jr $ra
svexit:
li $v1, 0
jr $ra


sides01:
	# Generate a direction
	li $v0, 42
	li $a0, 69
	li $a1, 2
	syscall
	move $t0, $a0
	# Generate an i and j
	li $v0, 42
	li $a0, 69
	addi $t1, $zero, 5
	sub $a1, $t1, $t0 
	syscall
	move $t1, $a0
	
	li $v0, 42
	li $a0, 69
	addi $t2, $zero, 6
	add $a1, $t2, $t0
	syscall
	move $t2, $a0
	move $t3, $zero
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	bnez $t0, sides01vedge
	j sides01hedge
	
	
	sides01hedgeIncrement:
	bnez $t3, sides01Exit
	addi $t3, $t3, 1
	
	sides01hedge:
	jal randhedge
	beqz $v1, sides01vedgeIncrement
	j sides01Exit
	
	sides01vedgeIncrement:
	bnez $t3, sides01Exit
	addi $t3, $t3, 1
	
	sides01vedge:
	jal randvedge
	beqz $v1, sides01hedgeIncrement
	j sides01Exit
	
sides01Exit:
	lw $ra, 0($sp)	
	addi $sp, $sp, 4
	jr $ra
	
randhedge:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
    move $a1, $t1 # t1 contains i
    move $a2, $t2 # t2 contains j
    rhloop:
    jal safehedge # call safehedge
    bnez $v1, rhtrue # if true, then return true
        addi $a2, $a2, 1 # else, increment column
        bne $a2, 7, rhloopexit # if not end column, update loop
            li $a2, 0 # else, set column to 0
            addi $a1, $a1, 1 # increment row by 1 
            ble $a1, 5, rhloopexit # if less than or equal to end row, update loop
                li $a1, 0 # set row to 0
    rhloopexit:
    bne $a1, $t1, rhloop # OR statement
    bne $a2, $t2, rhloop # loop if either satisfy
rhexit:
li $v1, 0
lw $ra, 0($sp)	
	addi $sp, $sp, 4
jr $ra
rhtrue:
li $v1, 1
move $v0, $a2
sll $v0, $v0, 3
add $v0, $v0, $a1
sll $v0, $v0, 1
lw $ra, 0($sp)	
addi $sp, $sp, 4
jr $ra

randvedge:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
    move $a1, $t1 # t4 contains i
    move $a2, $t2 # t5 contains j
    rvloop:
    jal safevedge # call safehedge
    bnez $v1, rvtrue # if true, then return true
        addi $a2, $a2, 1 # else, increment column
        bne $a2, 8, rvloopexit # if not end column, update loop
            li $a2, 0 # else, set column to 0
            addi $a1, $a1, 1 # increment row by 1 
            ble $a1, 4, rvloopexit # if less than or equal to end row, update loop
                li $a1, 0 # set row to 0
    rvloopexit:
    bne $a1, $t1, rvloop # OR statement
    bne $a2, $t2, rvloop # loop if either satisfy
rvexit:
li $v1, 0
	lw $ra, 0($sp)	
	addi $sp, $sp, 4
jr $ra
rvtrue:
li $v1, 1
move $v0, $a2
sll $v0, $v0, 3
add $v0, $v0, $a1
sll $v0, $v0, 1
addi $v0, $v0, 1
lw $ra, 0($sp)	
	addi $sp, $sp, 4
jr $ra

takeEdge:
		addi $sp, $sp, -36
		sw $ra, 0($sp)
		sw $t0, 4($sp)
		sw $t1, 8($sp)
		sw $t2, 12($sp)
		sw $t3, 16($sp)
		sw $t4, 20($sp)
		sw $t5, 24($sp)
		sw $t6, 28($sp)
		sw $t7, 32($sp)
		
		li $a1, COLOR_PLAYER_COMPUTER
		li $a2, 1
		jal DrawLine
		
		lw $ra, 0($sp)
		lw $t0, 4($sp)
		lw $t1, 8($sp)
		lw $t2, 12($sp)
		lw $t3, 16($sp)
		lw $t4, 20($sp)
		lw $t5, 24($sp)
		lw $t6, 28($sp)
		lw $t7, 32($sp)
		addi $sp, $sp, 36
		jr $ra
		
		
#function sac(i,j) {     //sacrifices two squares if there are still 3's
#    count=0;
#	loop=false;
#	incount(0,i,j);
#	if (!loop) takeallbut(i,j);
#	if (count+score[0]+score[1]==m*n) {
#		takeall3s()
#	} else {
#		if (loop) {
#			count=count-2;
#		}
#		outcount(0,i,j);
#		i=m;
#		j=n
#	}
#}
		
sacrifice:
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		li $t0, 0	# represents whether a loop detected or not 
		li $s7, 0	# Represents count of 3s
		
		li $a1, 0
		jal incount
		bnez $t0, skipTakeAllBut
		# jal takeAllBut
	skipTakeAllBut:
		lb $t1, playerScores
		lb $t2, playerScores
		add $t2, $t2, $t1
		add $t2, $t2, $s7
		bne $t2, 35, checkSacElse
		jal takeall3s
		j checkSacEnd
	checkSacElse:
		bnez $t0, checkSacSkip
		addi $s7, $s7, -2
		
	checkSacSkip:
		li $a1, 0
		jal outcount
		li $a0, 0x68
		
	checkSacEnd:
		
		lw $ra, 0($sp)	
		addi $sp, $sp, 4
		jr $ra
		
# incount(byteLine b, direction d)
# b represents a box, d is 0,1,2,3,4 for null, left, up, right, down

# function incount(k,i,j) {  //enter with box[i][j]=3 and k=0
#    count++;               //returns count = number in chain starting at i,j
#	if (k!=1 && vedge[i][j]<1) {     //k=1,2,3,4 means skip left,up,right,down.
#		if (j>0) {
#			if (box[i][j-1]>2) {
#				count++;
#				loop=true;
#			} else if (box[i][j-1]>1) incount(3,i,j-1);
#		}
#	} else if (k!=2 && hedge[i][j]<1) {
#		if (i>0) {
#			if (box[i-1][j]>2) {
#				count++;
#				loop=true
#			} else if (box[i-1][j]>1) incount(4,i-1,j);
#		}
#	} else if (k!=3 && vedge[i][j+1]<1) {
#		if (j<n-1) {
#			if (box[i][j+1]>2) {
#				count++;
#				loop=true
#			} else if (box[i][j+1]>1) incount(1,i,j+1);
#		}
#	} else if (k!=4 && hedge[i+1][j]<1) {
#		if (i<m-1) {
#			if (box[i+1][j]>2) {
#				count++;
#				loop=true
#			} else if (box[i+1][j]>1) incount(2,i+1,j);
#		}
#	}
#}
incount:
		addi $sp, $sp, -12
		lw $a1, 8($sp)
		sw $a0, 4($sp)
		sw $ra, 0($sp)
		addi $s7, $s7, 1
	dir1:
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		beq $a1, 1, dir2
		
		srl $t3, $a0, 1
		srl $t4, $t3, 3
		andi $t3, $t3, 7
		mul $t5, $t3, 8
		add $t5, $t5, $t4
		lb $t5, VerticalArr($t5)
		bnez $t5, dir2
		
		blez $t4, icexit
		
		addi $t4, $t4, -1
		mul $t5, $t3, 8
		add $t5, $t5, $t4
		lb $t5, VerticalArr($t5)
		blt $t5, 2, icexit
		bne $t5, 2, dir1Else
		
		addi $a1, $zero, 3
		jal incount
		j icexit
		
	dir1Else:
		addi $s7, $s7, 1
		addi $t0, $zero, 1
		
	dir2:
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		beq $a1, 2, dir3
		
		srl $t3, $a0, 1
		srl $t4, $t3, 3
		andi $t3, $t3, 7
		mul $t5, $t3, 7
		add $t5, $t5, $t4
		lb $t5, HorizontalArr($t5)
		bnez $t5, dir3
		
		blez $t3, icexit
	
		addi $t3, $t3, -1
		mul $t5, $t3, 7
		add $t5, $t5, $t4
		lb $t5, HorizontalArr($t5)
		blt $t5, 2, icexit
		bne $t5, 2, dir2Else
		
		addi $a1, $zero, 4
		jal incount
		j icexit
		
	dir2Else:
		addi $s7, $s7, 1
		addi $t0, $zero, 1
		
		
	dir3:
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		beq $a1, 3, dir4
		
		srl $t3, $a0, 1
		srl $t4, $t3, 3
		andi $t3, $t3, 7
		addi $t4, $t4, 1
		mul $t5, $t3, 8
		add $t5, $t5, $t4
		lb $t5, VerticalArr($t5)
		bnez $t5, dir4
	
		
		bgt $t4, 5, icexit
		
		addi $t4, $t4, 1
		mul $t5, $t3, 8
		add $t5, $t5, $t4
		lb $t5, VerticalArr($t5)
		blt $t5, 2, icexit
		bne $t5, 2, dir3Else
		
		addi $a1, $zero, 1
		jal incount
		j icexit
		
	dir3Else:
		addi $s7, $s7, 1
		addi $t0, $zero, 1
		
	dir4:
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		beq $a1, 4, icexit
		
		srl $t3, $a0, 1
		srl $t4, $t3, 3
		andi $t3, $t3, 7
		addi $t3, $t3, 1
		mul $t5, $t3, 7
		add $t5, $t5, $t4
		lb $t5, HorizontalArr($t5)
		bnez $t5, icexit
		
		bgt $t4, 3 icexit
		
		addi $t3, $t3, 1
		mul $t5, $t3, 7
		add $t5, $t5, $t4
		lb $t5, HorizontalArr($t5)
		blt $t5, 2, icexit
		bne $t5, 2, dir4Else
		
		addi $a1, $zero, 2
		jal incount
		j icexit
		
	dir4Else:
		addi $s7, $s7, 1
		addi $t0, $zero, 1
		
	icexit:
		lw $a1, 8($sp)
		lw $a0, 4($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 12
		jr $ra
	
outcount: 
		addi $sp, $sp, -12
		lw $a1, 8($sp)
		sw $a0, 4($sp)
		sw $ra, 0($sp)
		beqz $s7, ocexit
	odir1:
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		beq $a1, 1, dir2
		
		srl $t3, $a0, 1
		srl $t4, $t3, 3
		andi $t3, $t3, 7
		mul $t5, $t3, 8
		add $t5, $t5, $t4
		lb $t5, VerticalArr($t5)
		bnez $t5, dir2
		
		beq $s7, 2, odir1Else
		
		sll $a0, $t3, 1
		sll $a1, $t4, 4
		add $a0, $a0, $a1
		addi $a0, $a1, 1
		li $a1, COLOR_PLAYER_COMPUTER
		li $a2, 1
		jal DrawLine
		
		
	odir1Else:
		addi $s7, $s7, -1
		
		addi $a1, $zero, 3
		jal outcount
		j ocexit
		
	odir2:
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		beq $a1, 2, dir3
		
		srl $t3, $a0, 1
		srl $t4, $t3, 3
		andi $t3, $t3, 7
		mul $t5, $t3, 7
		add $t5, $t5, $t4
		lb $t5, HorizontalArr($t5)
		bnez $t5, dir3
		
		blez $t3, odir2Else
	
		
		sll $a0, $t3, 1
		sll $a1, $t4, 4
		add $a0, $a0, $a1
		li $a1, COLOR_PLAYER_COMPUTER
		li $a2, 1
		jal DrawLine
		
	odir2Else:
		
		addi $s7, $s7, -1
		
		addi $a1, $zero, 4
		jal outcount
		j ocexit
	odir3:
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		beq $a1, 3, dir4
		
		srl $t3, $a0, 1
		srl $t4, $t3, 3
		andi $t3, $t3, 7
		addi $t4, $t4, 1
		mul $t5, $t3, 8
		add $t5, $t5, $t4
		lb $t5, VerticalArr($t5)
		bnez $t5, odir4
	
		
		bgt $t4, 5 odir3Else
		
		sll $a0, $t3, 1
		sll $a1, $t4, 4
		add $a0, $a0, $a1
		addi $a0, $a0, 16
		addi $a0, $a0, 1
		li $a1, COLOR_PLAYER_COMPUTER
		li $a2, 1
		jal DrawLine
		
	odir3Else:
		
		addi $s7, $s7, -1
		
		addi $a1, $zero, 1
		jal outcount
		j ocexit
	odir4:
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		beq $a1, 4, ocexit
		
		srl $t3, $a0, 1
		srl $t4, $t3, 3
		andi $t3, $t3, 7
		addi $t3, $t3, 1
		mul $t5, $t3, 7
		add $t5, $t5, $t4
		lb $t5, HorizontalArr($t5)
		bnez $t5, ocexit
		
		bgt $t4, 3 ocexit
		
		sll $a0, $t3, 1
		sll $a1, $t4, 4
		add $a0, $a0, $a1
		addi $a0, $a0, 2
		li $a1, COLOR_PLAYER_COMPUTER
		li $a2, 1
		jal DrawLine
		
	odir4Else:
		
		addi $s7, $s7, -1
		
		addi $a1, $zero, 2
		jal outcount
		j ocexit
	ocexit:
		lw $a1, 8($sp)
		lw $a0, 4($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 12
		jr $ra
		
makeAnyMove:
	# Generate a direction
	li $v0, 42
	li $a0, 69
	li $a1, 2
	syscall
	move $t0, $a0
	# Generate an i and j
	li $v0, 42
	li $a0, 69
	addi $t1, $zero, 5
	sub $a1, $t1, $t0 
	syscall
	move $t1, $a0
	
	li $v0, 42
	li $a0, 69
	addi $t2, $zero, 6
	add $a1, $t2, $t0
	syscall
	move $t2, $a0
	move $t3, $zero
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	bnez $t0, anyvedge
	j anyhedge
	
	
	anyhedgeIncrement:
	bnez $t3, anyExit
	addi $t3, $t3, 1
	
	anyhedge:
	jal randhedge2
	beqz $v1, anyvedgeIncrement
	j anyExit
	
	anyvedgeIncrement:
	bnez $t3, anyExit
	addi $t3, $t3, 1
	
	anyvedge:
	jal randvedge2
	beqz $v1, anyhedgeIncrement
	j anyExit
	
anyExit:
	lw $ra, 0($sp)	
	addi $sp, $sp, 4
	jr $ra
	
randhedge2:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
    move $a1, $t1 # t1 contains i
    move $a2, $t2 # t2 contains j
    rhloop2:
    mul $t3, $a1, 7
    add $t3, $t3, $a2
    lb $t3, HorizontalArr($t3)
    beqz $t3, rhtrue2
        addi $a2, $a2, 1 # else, increment column
        bne $a2, 7, rhloopexit2 # if not end column, update loop
            li $a2, 0 # else, set column to 0
            addi $a1, $a1, 1 # increment row by 1 
            ble $a1, 5, rhloopexit2 # if less than or equal to end row, update loop
                li $a1, 0 # set row to 0
    rhloopexit2:
    bne $a1, $t1, rhloop2 # OR statement
    bne $a2, $t2, rhloop2 # loop if either satisfy
rhexit2:
li $v1, 0
lw $ra, 0($sp)	
	addi $sp, $sp, 4
jr $ra
rhtrue2:
li $v1, 1
move $v0, $a2
sll $v0, $v0, 3
add $v0, $v0, $a1
sll $v0, $v0, 1
lw $ra, 0($sp)	
addi $sp, $sp, 4
jr $ra

randvedge2:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
    move $a1, $t1 # t4 contains i
    move $a2, $t2 # t5 contains j
    rvloop2:
    mul $t3, $a1, 8
    add $t3, $t3, $a2
    lb $t3, VerticalArr($t3)
    beqz $t3, rvtrue2
        addi $a2, $a2, 1 # else, increment column
        bne $a2, 8, rvloopexit2 # if not end column, update loop
            li $a2, 0 # else, set column to 0
            addi $a1, $a1, 1 # increment row by 1 
            ble $a1, 4, rvloopexit2 # if less than or equal to end row, update loop
                li $a1, 0 # set row to 0
    rvloopexit2:
    bne $a1, $t1, rvloop2 # OR statement
    bne $a2, $t2, rvloop2 # loop if either satisfy
rvexit2:
li $v1, 0
	lw $ra, 0($sp)	
	addi $sp, $sp, 4
jr $ra
rvtrue2:
li $v1, 1
move $v0, $a2
sll $v0, $v0, 3
add $v0, $v0, $a1
sll $v0, $v0, 1
addi $v0, $v0, 1
lw $ra, 0($sp)	
	addi $sp, $sp, 4
jr $ra
		
