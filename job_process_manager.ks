@lazyglobal off.

// add to OS
parameter os_data.
register_program(os_data,"Process manager","run_process_manager",false).

function run_process_manager{
	parameter
		os_data,
		window_index.
	
	local process is list(
		make_process_system_struct(
			os_data,"update_process_manager",window_index,"Process manager"
		),
		"just_created","child_process","selected_process_id",
		"saved_process_list"
	).
	return process.
}

function draw_process_manager_status{
	parameter process.

	if not has_focus(process){
		return 0.
	}
	local run_mode is process[1].
	if run_mode<>"just_created"{ // pass status redraw event to child
		local child_process is process[2].
		invalidate_process_status(child_process).
	}
	validate_process_status(process).
}

function draw_process_manager{
	parameter process.

	if not is_process_gui(process){
		return 0.
	}
	local run_mode is process[1].
	if run_mode<>"just_created"{
		local child_process is process[2].
		local window_index is get_process_window_index(process).
		change_process_window(child_process,window_index).
	}
	validate_process_window(process).
}

function get_process_window_string{
	parameter proc.

	if not is_process_gui(proc){
		return "BG". // short for background. Clear?
	}
	return get_process_window_index(proc).
}

function update_process_manager{
	parameter process.

	if process_needs_redraw(process){
		draw_process_manager(process).
	}
	if process_status_needs_redraw(process){
		draw_process_manager_status(process).
	}
	
	// restore:
	local run_mode is process[1].
	local child_process is process[2].
	local selected_pid is process[3].
	local saved_process_list is process[4].
	local os_data is get_process_os_data(process).

	local child_return is 0.
	if run_mode<>"just_created"{
		set child_return to update_process(child_process).
	}

	if run_mode="just_created"{
		local lp is list().
		set saved_process_list to get_process_list(os_data):copy().
		for proc in saved_process_list{
			lp:add(
				get_process_name(proc)+
				" @ "+get_process_window_string(proc)
			).
		}
		lp:add("Quit").
		draw_empty_background(get_process_window(process)).
		set child_process to run_menu(
			os_data,get_process_window_index(process),"Select process:",
			lp,true
		).
		set run_mode to "process_selection".
	}
	else if run_mode="process_selection"{
		if process_finished(child_process){
			local selected_index is child_return.
			if selected_index>=saved_process_list:length(){ // "Quit"
				kill_process(process).
				return 0.
			}
			set selected_pid to get_process_id(
				saved_process_list[selected_index]
			).
			local options is list().
			options:add("Kill").
			options:add("Change window").
			options:add("Cancel").
			draw_empty_background(get_process_window(process)).
			set child_process to run_menu(
				os_data,get_process_window_index(process),"Select action:",
				options,false
			).
			set run_mode to "action_selection".
		}
	}
	else if run_mode="action_selection"{
		if process_finished(child_process){
			local action is child_return.
			if action="Kill"{
				for proc in get_process_list(os_data){
					if get_process_id(proc)=selected_pid{
						kill_process(proc).
					}
				}
				set run_mode to "just_created".
			}
			else if action="Change window"{
				local len is get_window_list(os_data):length.
				local lw is list().
				local i is 0.
				until i=len{
					lw:add(i).
					set i to i+1.
				}
				lw:add("Background").
				lw:add("Cancel").
				draw_empty_background(get_process_window(process)).
				set child_process to run_menu(
					os_data,get_process_window_index(process),
					"Select window:",lw,false
				).
				set run_mode to "window_selection".
			}
			else if action="Cancel"{
				set run_mode to "just_created".
			}
			else{
				print "Shouldn't happen.". print 1/0.
			}
		}
	}
	else if run_mode="window_selection"{
		if process_finished(child_process){
			local window_selection is child_return.
			if window_selection<>"Cancel"{
				if window_selection="Background"{
					set window_selection to -1.
				}
				for proc in get_process_list(os_data){
					if get_process_id(proc)=selected_pid{
						if is_process_gui(proc){
							draw_empty_background(get_process_window(proc)).
						}
						change_process_window(proc,window_selection).
					}
				}
			}
			set run_mode to "just_created".
		}
	}
	
	// save:
	set process[1] to run_mode.
	set process[2] to child_process.
	set process[3] to selected_pid.
	set process[4] to saved_process_list.
}
