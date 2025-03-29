.text
#################################################################################################################################################################
#					Display differents states of the elevator for movements and emergencies							#
#################################################################################################################################################################
#
# Printing is not done in the basic Mars Console (in "Run I/O") but in the MMIO Simulator
#
# We print in the MMIO Simulator using:
#
# 	For strings:
#		la $a0 <Address of the string to print>
#		jal display_str_MMIO
#
# 	For Integers:
#		la $t0 <Address of the Integer>
#		lw $a0 0($t0)
#		jal display_int_MMIO
#
# 	*See line 240 for more information*
#
display_status:
	addi $sp $sp -4				# Store $ra to call other methods.
	sw $ra 0($sp)				#/
	
	la $a0 clear				# Clear the screen
	jal display_str_MMIO			#/
	
	# Print the top of the elevator with Floor number \/
	la $a0 top_line_start
	jal display_str_MMIO
	
	
	la $t0 current_floor
	lw $a0 0($t0)
	jal display_int_MMIO
	
	la $a0 top_line_end
	jal display_str_MMIO
	# /\
	
	# Check if we have to display an emergency
	la $t0 emergency
	lw $t1 0($t0)
	bne $t1 $zero display_emergency
	
	# Print and decide which direction the elevator is going
	# dir == 0; Idle	dir == -1; Going down	     dir == 1; Going Up
	la $a0 top_arrow
	jal display_str_MMIO
	la $t2 current_dir
	lw $t3 0($t2)
	li $t4 1
	beq $t3 $t4 display_up
	li $t4 -1
	beq $t3 $t4 display_down
	
	# if dir == 0
	j display_idle

# Display the whole Elevator of when dir == 1
display_up:	
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 up_arrow
	jal display_str_MMIO
	
	la $a0 floor_requests_top
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 arrow_tail
	jal display_str_MMIO
	
	jal display_rest
	
	la $a0 space
	jal display_str_MMIO
	
	j stop_displaying

# Display the whole Elevator of when dir == -1
display_down:
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 arrow_tail
	jal display_str_MMIO
	
	la $a0 floor_requests_top
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 down_arrow
	jal display_str_MMIO
	
	jal display_rest
	
	
	la $a0 space
	jal display_str_MMIO
	
	j stop_displaying

# Display the whole Elevator of when dir == 0
display_idle:
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 idle_arrow
	jal display_str_MMIO
	
	la $a0 floor_requests_top
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 idle_arrow
	jal display_str_MMIO

# Display the rest of the elevator, gets called whatever the current dir is.
display_rest:
	
	la $a0 floor_requests_678
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 arrow_case_bot
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 number_case_top
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 number_case_1
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 number_case_2
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 number_case_3
	jal display_str_MMIO
	
	la $a0 door_bottom_pos1
	jal display_str_MMIO
	la $a0 number_case_bottom
	jal display_str_MMIO
	
	la $a0 prompt
	jal display_str_MMIO
	
	j stop_displaying

# Display Elevator when there is an emergency
display_emergency:
	# Set up the elevator so it doesn't move
	la $t0 elevator_stable
    	li $t1 1
    	sw $t1 0($t0)
	
	# Display the whole elevator when there is an emergency.
	la $a0 newline2
	jal display_str_MMIO
	
	la $t0 emergency_frame
	li $t1 0
	sw $t1 0($t0)
			
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 alarm_case_top
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 alarm_case_line1
	jal display_str_MMIO
	la $a0 light_open_top
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 alarm_case_line2
	jal display_str_MMIO
	la $a0 light_open_1
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 alarm_case_line3
	jal display_str_MMIO
	la $a0 light_open_2
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 alarm_case_line4
	jal display_str_MMIO
	la $a0 light_platform
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	la $a0 alarm_case_bottom
	jal display_str_MMIO
	
	la $a0 door_mid_pos1
	jal display_str_MMIO
	
	la $a0 newline2
	jal display_str_MMIO
	la $a0 door_bottom_pos1
	jal display_str_MMIO
	
	la $a0 prompt_alarm
	jal display_str_MMIO
	
	j stop_displaying

# Finished displaying
stop_displaying:
	lw $ra 0($sp)
	addi $sp $sp 4
	jr $ra

#################################################################################################################################################################
#					Reproduction of syscall 1 & 4 to Display in the MMIO DISPLAY View							#
#################################################################################################################################################################
#
# To Uses:
# - Store the value you want to print in $a0.
# - "jal display_str_MMIO" to print a String.
# - "jal display_int_MMIO" to print an Integer.
#
# Example:
#	la $a0 string
#	jal display_str_MMIO
#
#	move $a0 $t1
#	jal display_int_MMIO
#


# SYSCALL 4 (Print Strings)
# Loop char by char in the String to print them until '\0'
display_str_MMIO:
	lb $t0 0($a0)
	beqz $t0 exit_MMIO_display
	
	li $t1 0xFFFF000C # Address to print in MMIO
	sb $t0 0($t1)
	
	addi $a0 $a0 1
	j display_str_MMIO
# END SYSCALL 4

# START SYSCALL 1 (Print Integers).
display_int_MMIO:
	beq $a0 $zero int_MMIO_print_zero		# Special case to print '0'. Never used but it exist
	
	move $t2 $a0					
	la $t0 intBuffer
	li $t3 0

# Divide the integer until the quotient (LO register) is 0. Result in $t5 and translated to char value (+ '0').
int_MMIO_div_loop:
	beq $t2 $zero int_MMIO_div_end
	li $t4 10
	div $t2 $t4
	mfhi $t5
	mflo $t2
	addi $t5 $t5 48 			# 48 == '0'
	sb $t5 0($t0) 				# Store char in intBuffer
	addi $t0 $t0 1
	addi $t3 $t3 1
	j int_MMIO_div_loop


int_MMIO_div_end:
	# End buffer with '\0'
	li $t6 0
	sb $t6 0($t0)
	
	# reverse String preparation
	la $t7 intBuffer
	la $t8 intBuffer
	add $t8 $t8 $t3
	addi $t8 $t8 -1

# Reverse the string in inputBuffer
# $t7 and $t8 are both side of the string, and switch between each others until they are equal
int_MMIO_reverse_loop:
	bge $t7 $t8 int_MMIO_print_digits # End if all char are reversed
	
	lb $t9 0($t7)
	lb $s0 0($t8)
	sb $s0 0($t7)
	sb $t9 0($t8)
	addi $t7 $t7 1
	addi $t8 $t8 -1
	j int_MMIO_reverse_loop

# Prepare to print for print_loop
int_MMIO_print_digits:
	la $t0 intBuffer

# Print integers stored in intBuffer.
int_MMIO_print_loop:
	lb $t1 0($t0)
	beqz $t1 exit_MMIO_display
	li $t2 0xFFFF000C # Address to print in MMIO
	sb $t1 0($t2)
	addi $t0 $t0 1
	j int_MMIO_print_loop

# Print integer 0
int_MMIO_print_zero:
	li $t0 48
	li $t1 0xFFFF000C # Address to print in MMIO
	sb $t0 0($t1)
	j exit_MMIO_display
# END SYSCALL 1

exit_MMIO_display:
	jr $ra
