.text
.globl main
#################################################################################################################################################################
#							Main method to run the Elevator Simulation								#
#################################################################################################################################################################
main:
	jal init_program
	jal display_status

main_loop:
	jal handle_requests			# Handle User inputs in MMIO
	
	li $a0 100 				# Sets a delay of 500ms (100*5)
	jal delay				#/
	
	la $t0 emergency			# Switch to the Emergency loop if an emergency occured
	lw $t1 0($t0)				#
	bne $t1 $zero emergency_display		#/
	
	jal move_elevator
	jal display_status
	
	j main_loop

emergency_display:
	jal display_status			# Display emergency

emergency_loop:
	jal handle_requests
	
	la $t0 emergency			# Switch to the Main loop if the emergency stopped
	lw $t1 0($t0)				#
	beqz $t1 exit_emergency			#/
	
	j emergency_loop

exit_emergency:
	jal display_status			# Properly Display the Elevator before returning to main_loop
	j main_loop				#/

stop_program:
	li $v0 10				# Exit
	syscall					#/


.include "data.asm"
.include "init.asm"
.include "request_handler.asm"
.include "elevator_movement.asm"
.include "display.asm"
.include "timer.asm"
