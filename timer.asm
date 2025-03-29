.text
#################################################################################################################################################################
#							Creates a delay between floors. 									#
#################################################################################################################################################################
#
# Make the code sleep for 5*($a0) milliseconds. Take $a0 as an argument.
# Call handle requests every $a0 ms, so the user can enter inputs while the elevator is moving.
#
delay:
	# Store values to restore later
	addi $sp $sp -12
	li $t1 5
	sw $ra 8($sp)
	sw $t1 4($sp)
	sw $a0 0($sp)
	
	# set loop requests to 0 to execute check_once.
	la $t8  loop_requests
	li $t3, 0
	sw $t3 0($t8)

# loop $t1 times (5)	
delay_loop:
	lw $a0 0($sp)
	
	li $v0 32
	syscall
	
	jal handle_requests # Check for char in MMIO every $a0 ms
	lw $t1 4($sp)
	addi $t1 $t1 -1
	blt $t1 $zero delay_end
	sw $t1 4($sp)
	j delay_loop

# Restore values and return
delay_end:
	
	la $t8  loop_requests
	li $t3, 1
	sw $t3 0($t8)
	
	lw $ra 8($sp)
	addi $sp $sp 12
	jr $ra
