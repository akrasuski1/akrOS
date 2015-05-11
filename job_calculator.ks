@lazyglobal off.

run job_number_dialog.

// add to OS
parameter os_data.
register_program(os_data,"Calculator","run_calculator",false).

function run_calculator{
	parameter
		os_data,
		window_index.

	local process is list(
		make_process_system_struct(
			os_data,"update_calculator",window_index,"Calculator"
		),
		"just_started", // run_mode
		"ag8",          // last ag8 state
		"ag9",          // last ag9 state
		0,              // child process, if any. Otherwise 0.
		0,              // first number
		"+",            // operator
		0,              // second number
		0               // result of the operation
	).
	return process.
}

function draw_calculator{
	parameter process.
	
	if not is_process_gui(process){
		return 0.
	}
	
	local run_mode is process[1].
	local child_process is process[4].
	if child_process<>0{ // pass redraw to child
		local window_index is get_process_window_index(process).
		change_process_window(child_process,window_index).
	}
	else if run_mode="display_result"{ // redraw it yourself
		local window is get_process_window(process).
		local x is window[0].
		local y is window[1].

		local first_number is process[5].
		local operator is process[6].
		local second_number is process[7].
		local result is process[8].

		print first_number+operator+second_number+"="+result at(x+2,y+2).
	}
	validate_process_window(process).
}

function draw_calculator_status{
	parameter process.
	
	if not has_focus(process){
		return 0.
	}

	local run_mode is process[1].
	local child_process is process[4].
	if child_process<>0{ // pass redraw status event to child
		invalidate_process_status(child_process).
	}
	else{ // redraw it yourself
		local status_bar is get_status_window(os_data).
		local x is status_bar[0].
		local y is status_bar[1].

		print "Press 9 to close or 8 to restart." at(x+2,y+2).
	}
	validate_process_status(process).
}

function update_calculator{
	parameter process.
	
	// restore state:
	local run_mode is process[1].
	local child_process is process[4].
	local first_number is process[5].
	local operator is process[6].
	local second_number is process[7].
	local result is process[8].
	local os_data is get_process_os_data(process).
	local window_index is get_process_window_index(process).

	// input:
	local old_ag8 is process[2].
	set process[2] to ag8.
	local changed_ag8 is old_ag8<>process[2].

	local old_ag9 is process[3].
	set process[3] to ag9.
	local changed_ag9 is old_ag9<>process[3].

	if old_ag8="ag8" or not has_focus(process){
		set changed_ag8 to false.
		set changed_ag9 to false.
	}
	

	if process_needs_redraw(process){
		draw_calculator(process).
	}
	if process_status_needs_redraw(process){
		draw_calculator_status(process).
	}
	
	local child_return is 0.
	if child_process<>0{ // update child if needed
		set child_return to update_process(child_process).
	}

	if run_mode="just_started"{
		set child_process to run_number_dialog(
			os_data,
			window_index,
			"First number:",
			0
		).
		draw_status_bar(os_data).
		set run_mode to "input_first_number".
	}
	else if run_mode="input_first_number"{
		if process_finished(child_process){
			set first_number to child_return.
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			set child_process to run_menu(
				os_data,
				window_index,
				"Operator: ["+first_number+"_]",
				list("+","-","*","/","^"),
				false
			).
			set run_mode to "input_operator".
		}
	}
	else if run_mode="input_operator"{
		if process_finished(child_process){
			set operator to child_return.
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			set child_process to run_number_dialog(
				os_data,
				window_index,
				"Second number: ["+first_number+operator+"_]",
				0
			).
			set run_mode to "input_second_number".
		}
	}
	else if run_mode="input_second_number"{
		if process_finished(child_process){
			set second_number to child_return.
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			set child_process to 0. // no process
			set run_mode to "display_result".
			if operator="+"{
				set result to first_number+second_number.
			}
			else if operator="-"{
				set result to first_number-second_number.
			}
			else if operator="*"{
				set result to first_number*second_number.
			}
			else if operator="/"{
				set result to first_number/second_number.
			}
			else if operator="^"{
				set result to first_number^second_number.
			}
			invalidate_process_window(process). // print result
			invalidate_process_status(process). // print status
		}
	}
	else if run_mode="display_result"{
		if changed_ag8{
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			set child_process to run_number_dialog(
				os_data,
				window_index,
				"Input first number:",
				0
			).
			set run_mode to "input_first_number".
		}
		if changed_ag9{
			kill_process(process).
			return 0.
		}
	}
	else{
		print "Invalid run_mode: "+run_mode. print 1/0.
	}

	// save
	set process[1] to run_mode.
	set process[4] to child_process.
	set process[5] to first_number.
	set process[6] to operator.
	set process[7] to second_number.
	set process[8] to result.
}
