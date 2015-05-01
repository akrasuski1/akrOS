@lazyglobal off.

function open_window_akros_main_menu{
	parameter os_data.

	local process is list(
		make_process_system_struct(
			get_window_list(os_data),"update_window_akros_main_menu",0,
			"Main menu"
		),
		"title_screen",ag1,"child_proc_place","reserved","reserved",
		"selected_program",os_data
	).
	return process.
}

function draw_window_akros_main_menu{
	parameter process.
	
	if not is_process_gui(process){
		return 0.
	}

	local window is get_process_window(process).

	if window[2]>=26{
		print "aaa  k       OOOO SSSS" at(window[0]+2,window[1]+2).
		print "  a  k       O  O S   " at(window[0]+2,window[1]+3).
		print "aaa  k k rrr O  O SSSS" at(window[0]+2,window[1]+4).
		print "a a  kk  r   O  O    S" at(window[0]+2,window[1]+5).
		print "aaaa k k r   OOOO SSSS" at(window[0]+2,window[1]+6).
	}
	else{
		print "Welcome to akrOS." at(window[0]+2,window[1]+4).
	}

	print "Press 1 to start." at(window[0]+2,window[1]+8).

	print "v0.1, by akrasuski1" at(window[0]+window[2]-20,
									window[1]+window[3]-2).
	
	validate_process_window(process).
}

function update_window_akros_main_menu{
	parameter process.

	local run_mode is process[1].
	local wnd is get_process_window(process).
	local last_ag1 is process[2].
	set process[2] to ag1.
	local current_ag1 is process[2].
	local os_data is process[7].
	local child_process is process[3].
	
	local child_return is 0.
	if run_mode="program_selection" or run_mode="window_selection"
		or run_mode="waiting_for_foreground"{
		if process_needs_redraw(process){ // pass redraw event to child
			invalidate_process_window(child_process).
			validate_process_window(process).
		}
		set child_return to update_process(child_process).
	}

	if run_mode="title_screen"{
		if process_needs_redraw(process){
			draw_window_akros_main_menu(process).
		}

		local wnd is get_process_window(process).

		if current_ag1<>last_ag1{
			draw_empty_window(wnd).
			set process[1] to "program_selection".
			local options is get_program_list().
			options:add("Window Manager").
			options:add("Back").
			options:add("Quit akrOS").
			local child_process is open_window_menu(
				get_window_list(os_data),
				0,
				"Select program:",
				options,
				false
			).
			set process[3] to child_process.
		}
	}
	else if run_mode="program_selection"{
		if process_finished(child_process){
			local selection is child_return.
			draw_empty_window(wnd).
			if selection="Quit akrOS"{
				local all_proc is get_process_list(os_data).
				local i is 0.
				until i=all_proc:length{
					kill_process(all_proc[i]). //kill'em all
					set i to i+1.
				}
				return 0.
			}
			else if selection="Back"{
				set process[1] to "title_screen".
				invalidate_process_window(process).
			}
			else if selection="Window Manager"{
				set process[1] to "waiting_for_foreground".
				local child_process is open_window_manager(os_data).
				set process[3] to child_process.
			}
			else{
				local len is get_window_list(os_data):length.
				local lw is list().
				local i is 0.
				until i=len{
					lw:add(i).
					set i to i+1.
				}
				lw:add("Background").
				set child_process to open_window_menu(
					get_window_list(os_data),0,"Select window",lw,false
				).
				set process[1] to "window_selection".
				set process[3] to child_process.
				set process[6] to selection.
			}
		}
	}
	else if run_mode="window_selection"{
		if process_finished(child_process){
			local selection is child_return.
			if selection="Background"{
				set selection to -1.
			}
			draw_empty_window(wnd).
			
			local other_process is make_process_from_name(
				os_data,process[6],selection
			).

			if selection<>0{ // menu is still there
				local all_proc is get_process_list(os_data).
				all_proc:add(other_process).
				invalidate_process_window(process).
				set process[1] to "title_screen".
			}
			else{ // menu must disappear to show program
				set process[3] to other_process.
				set process[1] to "waiting_for_foreground".
			}
		}
	}
	else if run_mode="waiting_for_foreground"{
		if process_finished(child_process){
			set wnd to get_process_window(process). //need to reset in
			//case child changed windows (i.e. window manager)
			draw_empty_window(wnd).
			invalidate_process_window(process).
			set process[1] to "title_screen".
		}
	}
}
