.text
#################################################################################################################################################################
#							Handle User inputs and Requests 									#
#################################################################################################################################################################
#
# Possible Requests:
# 	Inside Elevator Floor Requests:
#		[1],[2],[3],[4],[5],[6],[7],[8],[9]
#	Special Requests (works in lowercase or UPPERCASE):
#		[E]mergency, [S]top Simulation, [R]eset
#	Floor Requests:
#		[+1],[-2],[+2],[-3],[+3],[-4],[+4],[-5],[+5],[-6],[+6],[-7],[+7],[-8],[+8],[-9]
#
# Depending on conditions we can either loop until the user inputs a requests, or just check one char.
#

# Check if we check_once or not.
handle_requests:
	la $t0 loop_requests
	lw $t1 0($t0)
	bnez $t1 check_dir_before_loop

check_once:
	# Check in MMIO if a character was entered
	li $t0 0xFFFF0000 # Address to check at
	lw $t1 0($t0)
	beqz $t1 ignore # No Inputs
	
	# Get the pressed input from the MMIO
	li $t0 0xFFFF0004
	lb $t2 0($t0)
	
	# If the user pressed [Enter], process requests
	li $t3 10 # 10 == [Enter]
	beq $t2 $t3 process_command
	
	# Else put it in the inputBuffer
	la $t4 inputBuffer
	la $t5 buffer_pos
	lw $t6 0($t5)
	add $t4 $t4 $t6
	sb $t2 0($t4)
	
	addi $t6 $t6 1
	sw $t6 0($t5)
	
# return
ignore:
	jr $ra

# Check if dir == 0, (loop requests), or if elevator is stable (1 = loop, 0 == check once)
check_dir_before_loop:
	la $t0 elevator_stable
	lw $t1 0($t0)
	beqz $t1 check_once
# bugfix for continuous requests, when elevator is stable, check thrue both lists to check if there is a request
check_lists:
	la $t0 up_list
	la $t1 down_list
	li $t2 9
check_lists_loop:
	beqz $t2 requests_loop # there is none
	lb $t3 0($t0)
	bnez $t3 continue_moving # there is one
	lb $t4 0($t1)
	bnez $t4 continue_moving # there is one
	addi $t0 $t0 1
	addi $t1 $t1 1
	addi $t2 $t2 -1
	j check_lists_loop

continue_moving:
	la $t0 elevator_stable
	sw $zero 0($t0)
	j clear_buffer

# Wait for user input in the MMIO
requests_loop:
	# Check in MMIO if a character was entered
	li $t0 0xFFFF0000 # Address to check at
	lw $t1 0($t0)
	beqz $t1 requests_loop # No Inputs
	
	# Get the pressed input from the MMIO
	li $t0 0xFFFF0004
	lb $t2 0($t0)
	
	# If the user pressed [Enter], process requests
	li $t3 10 # 10 == [Enter]
	beq $t2 $t3 process_command
	
	# Else put it in the inputBuffer, and continue to loop
	la $t4 inputBuffer
	la $t5 buffer_pos
	lw $t6 0($t5)
	add $t4 $t4 $t6
	sb $t2 0($t4)
	
	addi $t6 $t6 1
	sw $t6 0($t5)
	
	j requests_loop

# Process requests
process_command:
	# Set elevator to not stable
	la $t0 elevator_stable
	sw $zero 0($t0)
	
	la $t0 inputBuffer
	lb $t1 0($t0)
	beqz $t1 clear_buffer
	
	# Check for Emergency (If Input == 'e' OR 'E')
	li $t2 'E'
	beq $t1 $t2 set_emergency
	li $t2 'e'
	beq $t1 $t2 set_emergency
	
	# Check to reset
	li $t2 'R'
	beq $t1 $t2 reset_call
	li $t2 'r'
	beq $t1 $t2 reset_call
	
	# Check to stop program
	li $t2 'S'
	beq $t1 $t2 stop_program
	li $t2 's'
	beq $t1 $t2 stop_program
	
	# Check to going up requests
	li $t2 '+'
	beq $t1 $t2 check_plus_commands
	
	# Check to going down requests
	li $t2 '-'
	beq $t1 $t2 check_minus_commands
	
	# Basic elevator requests
	li $t2 '1'
	blt $t1 $t2 clear_buffer
	li $t2 '9'
	bgt $t1 $t2 clear_buffer
	
	la $t2 current_floor
	lw $t3 0($t2)
	
	# Check for basic requests ([1], [2]...) if the requested floor is above the current floor of the elevator or not. Also sotre in requested floor
	subu $a0 $t1 '0'
	bgt $a0 $t3 add_up_list
	blt $a0 $t3 add_down_list
	
	la $t4 current_dir
	lw $t5 0($t4)
	# Check current direction
	li $t6 1
	beq $t6 $t5 add_down_list
	li $t6 -1
	beq $t6 $t5 add_up_list
	
	

# Set emergency. Emergency is processed in main
set_emergency:
	la $t4 emergency
	li $t3 1
	sw $t3 0($t4)
	j clear_buffer

# Reset emergency if there was one
reset_call:
	la $t4 emergency
	li $t3 0
	sw $t3 0($t4)
	
	j clear_buffer

# Check requests Going up ([+4], [+5]...)
check_plus_commands:
	la $t0 inputBuffer
	lb $t1 1($t0)
	
	# check if its a valid command (between 1 and 8)
	li $t2 '1'
	blt $t1 $t2 clear_buffer
	li $t3 '8'
	bgt $t1 $t3 clear_buffer
	
	subu $t2 $t1 '0'
	
	# Add it to up list (requests for when the elevator is going upward.)
	addi $t2 $t2 -1
	la $t3 up_list
	add $t3 $t3 $t2
	
	# Store -1 in up list, so later it can be processed as a signed input (check elevator_movement.asm for more info)
	li $t4 -1
	sb $t4 0($t3)
	
	j clear_buffer
	
# Check for going down inputs ([-4], [-5]...)
check_minus_commands:
	la $t0 inputBuffer
	lb $t1 1($t0)
	
	# check if its a valid command (between 2 and 9)
	li $t2 '2'
	blt $t1 $t2 clear_buffer
	li $t3 '9'
	bgt $t1 $t3 clear_buffer
	
	subu $t2 $t1 '0'
	
	# Add it to down list, (requests for when the elevator is going downward.)
	addi $t2 $t2 -1
	la $t3 down_list
	add $t3 $t3 $t2
	
	# Store -1 in up list, so later it can be processed as a signed input (check elevator_movement.asm for more info)
	li $t4 -1
	sb $t4 0($t3)
	
	j clear_buffer

# Store Basic elevator request into up list
add_up_list:
	addi $a0 $a0 -1
	
	la $t3 up_list
	add $t3 $t3 $a0
	
	# Store 1 since its unsigned (check elevator_movement.asm for more info)
	li $t4 1
	sb $t4 0($t3)
	
	j clear_buffer

# Store Basic elevator requests into down list
add_down_list:
	addi $a0 $a0 -1
	
	la $t3 down_list
	add $t3 $t3 $a0
	
	# Store 1 since its unsigned (check elevator_movement.asm for more info)
	li $t4 1
	sb $t4 0($t3)
	
	j clear_buffer

# Clear buffer and return
clear_buffer:
	li $t6 0
	la $t5 buffer_pos
	sw $t6 0($t5)
	
	jr $ra





