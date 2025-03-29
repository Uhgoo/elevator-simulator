.text
#################################################################################################################################################################
#							Creates a delay between floors. 									#
#################################################################################################################################################################
#
# Definitions:
#	up_list: The list of floor requests that are either requests wanting to go up, or basic requests above the current position of the elevator.
#	down_list: The list of floor requests that are either requests wanting to go down, or basic requests below the current position of the elevator
#

# Determine how to check to move the elevator, based on the current dir
move_elevator:
	# Store $ra in $sp
	addi $sp $sp -4
	sw $ra 0($sp)
	
	la $t0 current_floor
	lw $t1 0($t0)
	la $t2 requested_floor
	
	la $t7 current_dir
	lw $t7 0($t7)
	
	bgez $t7 upward_checks   
	bltz $t7 downward_checks
	


#################################
#   UPWARD (current_dir >= 0)	#
#################################
#
# Check requests like that (example current floor == 5) (% = up_list, $ = down_list):
#
#	9:     %$
#	8:    %  $
#	7:   %    $
#	6:  %      $
#	5: %        $    
#	4:	     $   %
#	3:	      $   %
#	2:	       $   %
#	1:		$   %
#
# Check in that order for faster traversal.
#

upward_checks:
	li $t9 9 # max floor = 9
	move $t8 $t1
upward_check_up_loop:
	ble $t8 $t9 upward_check_up_body
	j upward_check_downlist # if max floor is reached, check downward.
upward_check_up_body:
	la $t4 up_list
	addi $t5 $t8 -1
	add $t4 $t4 $t5
	lb $t6 0($t4)
	bnez $t6 found_call_up # found a floor to move to.
	addi $t8 $t8 1
	j upward_check_up_loop
	

upward_check_downlist:
	li $t8 9 # start at floor 9
upward_downlist_loop:
	bge $t8 1 upward_downlist_body
	j upward_check_up_below   # if $t8 < 1, check up list but below current floor
upward_downlist_body:
	la $t4 down_list
	addi $t5 $t8 -1
	add $t4 $t4 $t5
	lb $t6 0($t4)
	bnez $t6 found_call_down # found a floor to move to
	addi $t8 $t8 -1
	j upward_downlist_loop

upward_check_up_below:
	move $t8 $t1 # $t8 = current_floor
	addi $t8 $t8 -1
upward_upbelow_loop:
	blt $t8 1 no_call_found # finished looping, no floor requests
	la $t4 up_list
	addi $t5 $t8 -1
	add $t4 $t4, $t5
	lb $t6 0($t4)
	bnez $t6 found_call_up # found a floor to move to
	addi $t8 $t8 -1
	j upward_upbelow_loop


#################################
#  DOWNWARD (current_dir < 0)	#
#################################
#
# Check requests like that (example current floor == 5) (% = up_list, $ = down_list):
#
#	9:		%   $
#	8:	       %   $
#	7:	      %   $
#	6:	     %   $
#	5: $	    %
#	4:  $      %
#	3:   $    %
#	2:    $  %
#	1:     $%
#
# Check in that order for faster traversal.
#

downward_checks:
	move $t8 $t1
downward_check_down_loop:
	bge $t8 1 downward_down_body
	j downward_check_uplist # min floor is reached, check upward
downward_down_body:
	la $t4 down_list
	addi $t5 $t8 -1
	add $t4 $t4, $t5
	lb $t6 0($t4)
	bnez $t6 found_call_down # found a floor to move to.
	addi $t8 $t8 -1
	j downward_check_down_loop

downward_check_uplist:
	li $t8 1 # Start at floor 1 to 9
	li $t9 9
downward_uplist_loop:
	ble $t8 $t9 downward_uplist_body
	j downward_check_down_above   # none find, check the rest of down list
downward_uplist_body:
	la $t4 up_list
	addi $t5 $t8, -1
	add $t4 $t4, $t5
	lb $t6 0($t4)
	bnez $t6 found_call_up # found a floor to move to.
	addi $t8 $t8 1
	j downward_uplist_loop

downward_check_down_above:
	move $t8 $t1 # $t8 = current_floor
	addi $t8 $t8 1
	li $t9 9
downward_downabove_loop:
	ble $t8 $t9 downward_downabove_body
	j no_call_found # no requests find in both list
downward_downabove_body:
	la $t4 down_list
	addi $t5 $t8 -1
	add $t4 $t4, $t5
	lb $t6 0($t4)
	bnez $t6 found_call_down # found a floor to move to.
	addi $t8 $t8 1
	j downward_downabove_loop

no_call_found:
	j arrived # exit to arrived if none find



#########################################
#   Actions for if a request was find	#
#########################################

# setup to move the elevator (upward)
found_call_up:
	move $t1 $t8
	addi $t1 $t1 -1
	la $t2 up_list
	add $t2 $t2 $t1
	lb $t3 0($t2)
	li $t4 -1
	beq $t3 $t4 set_plus_dir # if signed
	li $t5 0
	j set_dir_common_up # unsinged
set_plus_dir:
	li $t5 1
set_dir_common_up: 
	la $t6 current_dir
	sw $t5 0($t6)# setup requested floor to demand
	la $t7 requested_floor
	sw $t8 0($t7) # setup requested floor to demand
	j decide_direction 


# setup to move the elevator (downward)
found_call_down:
	move $t1 $t8
	addi $t1 $t1 -1
	la $t2 down_list
	add $t2 $t2 $t1
	lb $t3 0($t2)
	li $t4 -1
	beq $t3 $t4 set_minus_dir # if signed
	li $t5 0
	j set_dir_common_down # unsinged
set_minus_dir:
	li $t5 -1
set_dir_common_down:
	la $t6 current_dir
	sw $t5 0($t6) # setup requested floor to demand
	la $t7 requested_floor
	sw $t8 0($t7) # setup requested floor to demand
	j decide_direction



#################################
#  Moving elevator to a floor	#
#################################

# decide the direction of the movement
decide_direction:
	la $t2 requested_floor
	la $t0 current_floor
	lw $t1 0($t0) 
	lw $t8 0($t2)
	beq $t1 $t8 arrived # stay still
	blt $t1 $t8 move_up # move up
	bgt $t1 $t8 move_down # move down

# elevator arrived at floor
arrived:
	la $t0 requested_floor
	lw $t8 0($t0)    
	la $t1 current_dir
	lw $t2 0($t1)
	
	li $t3 1
	beq $t2 $t3 arrived_check_up # check up if dir == 1 
	li $t3 -1
	beq $t2 $t3 arrived_check_down # check down if dir == -1 
	
	li $t4 0
	sw $t4 0($t1)
	la $t5 loop_requests # loop requests
	li $t4 1
	sw $t4 0($t5)
	la $t0 elevator_stable # set elevator stable
	li $t1 1
	sw $t1 0($t0)
	j after_anim # go to clear lists

# arrived at floor going upward
arrived_check_up:
	la $t4 up_list
	addi $t5 $t8 -1
	add $t4 $t4 $t5
	lb $t6 0($t4)
	li $t7 -1
	beq $t6 $t7 arrived_signed # branch if the request was signed
	li $t0 0
	sw $t4 0($t1)
	la $t5 loop_requests # set loop requests to true
	li $t4 1
	sw $t4 0($t5)
	j after_anim # go to clear lists

# arrived at floor going downward
arrived_check_down:
	la $t4 down_list
	addi $t5 $t8 -1
	add $t4 $t4 $t5
	lb $t6 0($t4)
	li $t7 -1
	beq $t6 $t7 arrived_signed # branch if the request was signed
	li $t4 0
	sw $t4 0($t1)
	la $t5 loop_requests # set loop requests to true
	li $t4 1
	sw $t4 0($t5)
	j after_anim # go to clear lists

# set elevator to be stable
arrived_signed:
	la $t0 elevator_stable
	li $t1 1
	sw $t1 0($t0)
	j after_anim # go to clear lists

# set dir to 0
clear_dir:
	la $t1 current_dir
	sw $zero 0($t1)

# set loop_requests to true
set_loop_requests:
	la $t8 loop_requests
	li $t3 1
	sw $t3 0($t8)
	j after_anim # go to clear lists

# move the elevator up 1 floor
move_up:
	la $t7 current_dir
	li $t3 1
	sw $t3 0($t7) # set dir to 1
	la $t0 current_floor
	lw $t1 0($t0)
	addi $t1 $t1 1 # Go up 1 floor
	sw $t1 0($t0)
	j after_anim # go to clear lists

# move the elevator down 1 floor
move_down:
	la $t7 current_dir
	li $t3 -1
	sw $t3 0($t7) # set dir to -1
	la $t0 current_floor
	lw $t1 0($t0)
	addi $t1 $t1 -1 # Go down 1 floor
	sw $t1 0($t0)
	j after_anim # go to clear lists


#################################
# 	Clear Everything	#
#################################

# Called that because I originally planned to implement an animation.
# If we arrived to a requested floor, choose whether to clear up or down
after_anim:
	la $t0 current_floor
	lw $t1 0($t0)
	la $t2 requested_floor
	lw $t8 0($t2)
	bne $t1 $t8 stop_moving # If we didn't arrived to a requested floor
	
	# clear up if dir==1, down if dir==-1, stop and return else
	la $t7 current_dir
	lw $t3 0($t7)
	li $t4 1
	beq $t3 $t4 clear_up
	li $t4 -1
	beq $t3 $t4 clear_down
	j stop_moving


# if dir == 1, check if its in up_list, if so, check if its signed or not (signed == -1. unsigned == 1. sotred in lists)
clear_up:
	la $t2 requested_floor
	lw $t8 0($t2)
	la $t4 up_list
	addi $t5, $t8 -1
	add $t4 $t4 $t5
	lb $t9 0($t4)
	beqz $t9 check_down_list_byte # check same pos in down_list
	li $t0 -1
	beq $t0 $t9 clear_set_dir_up # Branch if signed request.
	# set current dir to 0 since unsigned.
	la $t7 current_dir
	sw $zero 0($t7)
	li $t6 0
	sb $t6 0($t4) # remove request from up_list
	j stop_moving_clear

# Process signed up requests
clear_set_dir_up:
	# set current dir to 1 since signed.
	la $t7 current_dir
	li $t3 1
	sw $t3 0($t7)
	li $t6 0
	sb $t6 0($t4) # remove request from up_list
	j stop_moving_clear

# check in up_list if there is a request at the current floor.
check_up_list_byte:
	la $t4 up_list
	addi $t5 $t8 -1
	add $t4 $t4 $t5
	lb $t9 0($t4)
	bnez $t9 clear_up # yes there is
	j stop_moving_clear # no

# check in down_list if there is a request at the current floor.
check_down_list_byte:
	la $t4 down_list
	addi $t5 $t8 -1
	add $t4 $t4 $t5
	lb $t9 0($t4)
	bnez $t9 clear_down # yes there is
	j stop_moving_clear # no

# if dir == -1, check if its in down_list, if so, check if its signed or not (signed == -1. unsigned == 1. stored in lists)
clear_down:
	la $t2 requested_floor
	lw $t8 0($t2)
	la $t4 down_list
	addi $t5 $t8 -1
	add $t4 $t4 $t5
	lb $t9 0($t4)
	beqz $t9 check_up_list_byte# check same pos in up_list
	li $t0 -1
	beq $t0 $t9 clear_set_dir_down # Branch if signed request.
	# set current dir to 0 since unsigned.
	la $t7 current_dir
	sw $zero 0($t7)
	li $t6 0
	sb $t6 0($t4) # remove request from down_list
	j stop_moving_clear

# Process signed down requests
clear_set_dir_down:
	# set current dir to -1 since signed.
	la $t7 current_dir
    	li $t3 -1
	sw $t3 0($t7)
	li $t6 0
	sb $t6 0($t4) # remove request from down_list
	j stop_moving_clear

#################################
# 	      END	 	#
#################################

# return by just restoring $ra
stop_moving:
	lw $ra 0($sp)
	addi $sp $sp 4
	jr $ra

# return by restoring $ra and setting the elevator to be stable.
stop_moving_clear:
	la $t0 elevator_stable
	li $t1 1
	sw $t1 0($t0)
	
	lw $ra, 0($sp)
	addi $sp $sp 4
	jr $ra



# La routine open_elevator est supposée être définie ailleurs.

