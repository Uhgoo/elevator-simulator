.data
	total_floors:		.word 9
	initial_floor:		.word 1
	dir_idle:		.word 0
	dir_up:			.word 1
	dir_down:		.word -1
	
	up_list:		.space 9
	down_list:		.space 9
	
	current_floor:		.word 1
	current_dir:		.word 0
	requested_floor:	.word 0
	loop_requests:		.word 0
	elevator_stable: 	.word 1
	
	emergency:		.word 0
	emergency_frame:	.word 0
	
	clear:			.asciiz "\n\n\n\n\n\n\n\n\n\n "
	newline:		.asciiz "\n "
	newline2:		.asciiz "\n"
	space:			.asciiz " "
	
	inputBuffer:		.space 256
	buffer_pos:		.word 0
	
	# ELEVATOR DISPLAY:
	
	top_line_start:		.asciiz "#######["
	top_line_end: 		.asciiz "]#######"
	top_arrow: 		.asciiz " \t+-----+\n"
	up_arrow:		.asciiz " \t| /|\\ |"
	down_arrow:		.asciiz " \t| \\|/ |"
	idle_arrow:		.asciiz " \t|     |"
	arrow_tail:		.asciiz " \t|  |  |"
	floor_requests_top:	.asciiz " \t+-----[Floor Requests]-----+\n"
	floor_requests_678:	.asciiz " \t| [+6] [+7] [+8]           |\n"
	arrow_case_bot:		.asciiz " \t+-----+ \t| [-6] [-7] [-8] [-9]      |\n"
	number_case_top:	.asciiz "  +-----------------+\t|\t\t\t   | E = Emergency\n"
	number_case_1:		.asciiz "  | [7] [8] [9]     |\t| [+1] [+2] [+3] [+4] [+5] | S = Stop Simulation \n"
	number_case_2:		.asciiz "  | [4] [5] [6] [E] |\t|      [-2] [-3] [-4] [-5] |\n"
	number_case_3:		.asciiz "  | [1] [2] [3] [S] |\t+--------------------------+\n"
	number_case_bottom:	.asciiz "  +-----------------+\n"
	door_mid_pos1:		.asciiz " #       |       #"
	door_bottom_pos1:	.asciiz " #_______|_______#"
	prompt:			.asciiz "Enter any of the [<commands>], and press [Enter] to execute it."
	prompt_alarm:		.asciiz "\nEnter [R]+[Enter] to Reset."
	intBuffer:		.space 12
	
	alarm_case_top:		.asciiz "\t+-----------[!!! WARNING !!!]-----------+\n"
	alarm_case_line1:	.asciiz "\t|\tAn emergency is happening\t|"
	alarm_case_line2:	.asciiz "\t|\t\t\t\t\t|"
	alarm_case_line3:	.asciiz "\t|      Enter [R]+[Enter] to cancel\t|"
	alarm_case_line4:	.asciiz "\t|\t      the emergency\t\t|"
	alarm_case_bottom:	.asciiz "\t+---------------------------------------+\n"
	
	light_open_top:		.asciiz "\t \\ __ /\n"
	light_open_1:		.asciiz "\t- /$$\\ -\n"
	light_open_2:		.asciiz "\t |$%%$|\n"
	light_close_top:	.asciiz "\t   __\n"
	light_close_1:		.asciiz "\t  /  \\\n"
	light_close_2:		.asciiz "\t | %% |\n"
	light_platform:		.asciiz "\t########\n"
	
