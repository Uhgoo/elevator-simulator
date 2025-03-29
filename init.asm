.data
	open_mmio_msg:	.asciiz "\n\nOpen Mars MMIO Simulator and enter Any Key in the 'KEYBOARD' field to start the program.\nGo to: \"Tools\" -> \"Keyboard and Display MMIO Simulator\" -> Press \"Connect to MIPS\"\n"

.text
#################################################################################################################################################################
#								Initialize the Elevator Simulation								#
#################################################################################################################################################################
init_program:
	
	la $t0 initial_floor
	lw $t1 0($t0)
	la $t2 current_floor
	sw $t1 0($t2)
	
	la $t6 emergency
	li $t7 0
	sw $t7 0($t6)
	
	la $t8 buffer_pos
	li $t9 0
	sw $t9 0($t8)
	
	li $v0 4
	la $a0 open_mmio_msg
	syscall

# Wait for user input in MMIO to start the main loop (Enter)
wait_loop:
	li $t0 0xFFFF0000
	lw $t1 0($t0)
	beqz $t1 wait_loop
	
	jr $ra
