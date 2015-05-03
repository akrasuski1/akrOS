@lazyglobal off.

function run_main_menu{
	parameter os_data.

	local process is list(
		make_process_system_struct(
			os_data,"update_main_menu",0,"Main menu"
		),
		"title_screen","ag9","child_process","program_selection"
	).
	return process.
	// main menu always runs in window 0 - otherwise it could get
	// accidentally backgrounded by window manager
}

function draw_main_menu{
	parameter process.
	
	if not is_process_gui(process){
		return 0.
	}
	
	local run_mode is process[1].
	local child_process is process[3].
	if run_mode<>"title_screen"{
		invalidate_process_window(child_process). // pass redraw to child
		validate_process_window(process).
		return 0.
	}

	local window is get_process_window(process).
	local x is window[0].
	local y is window[1].
	local w is window[2].
	local h is window[3].

	if w>=26{ // if enough place, print logo
		print "aaa  k       OOOO SSSS" at(x+2,y+2).
		print "  a  k       O  O S   " at(x+2,y+3).
		print "aaa  k k rrr O  O SSSS" at(x+2,y+4).
		print "a a  kk  r   O  O    S" at(x+2,y+5).
		print "aaaa k k r   OOOO SSSS" at(x+2,y+6).
	}
	else{ // otherwise, just short welcome message
		print "Welcome to akrOS." at(x+2,y+4).
	}

	print "Press 9 to start." at(x+2,y+8).

	print "v0.1, by akrasuski1" at(x+w-20,y+h-2). // bottom right
	
	validate_process_window(process).
}

function draw_main_menu_status{
	parameter process.
	
	if not has_focus(process){
		return 0.
	}

	local run_mode is process[1].
	if run_mode<>"title_screen"{ // pass redraw status event to child
		local child_process is process[3].
		invalidate_process_status(child_process).
	}
	else{
		local status_bar is get_status_window(os_data).
		local x is status_bar[0].
		local y is status_bar[1].
		print "Press 9 to start." at(x+2,y+2).
		print "1 and 2 switch window focus." at(x+2,y+3).
	}
	validate_process_status(process).
}

function create_main_menu_child{
	parameter process.

	local os_data is get_process_os_data(process).
	local wnd is get_process_window(process).

	draw_empty_background(wnd).
	local options is get_program_list(os_data).
	options:add("Back").
	options:add("Quit akrOS").
	local child_process is run_menu(
		os_data,
		0,
		"Main menu:",
		options,
		false
	).
	draw_empty_background(get_status_window(os_data)).

	return child_process.
}

function update_main_menu{
	parameter process.
	
	// restore state:
	local run_mode is process[1].
	local child_process is process[3].
	local program_selection is process[4].
	local os_data is get_process_os_data(process).
	local wnd is get_process_window(process).
	// input:
	local old_ag9 is process[2].
	set process[2] to ag9.
	local changed_ag9 is old_ag9<>process[2].

	if old_ag9="ag9" or not has_focus(process){
		set changed_ag9 to false.
	}
	

	if process_needs_redraw(process){
		draw_main_menu(process).
	}
	if process_status_needs_redraw(process){
		draw_main_menu_status(process).
	}
	
	local child_return is 0.
	if run_mode<>"title_screen"{ // update child if needed
		set child_return to update_process(child_process).
	}

	if run_mode="title_screen"{
		if changed_ag9{
			set child_process to create_main_menu_child(process).
			set run_mode to "program_selection".
		}
	}
	else if run_mode="program_selection"{
		if process_finished(child_process){
			set program_selection to child_return.
			draw_empty_background(wnd).
			if program_selection="Quit akrOS"{
				local all_proc is get_process_list(os_data).
				local i is 0.
				until i=all_proc:length{
					kill_process(all_proc[i]). // kill'em all
					set i to i+1.
				}
				return 0.
			}
			else if program_selection="Back"{
				set run_mode to "title_screen".
				invalidate_process_window(process).
			}
			else if is_system_program(os_data,program_selection){
				local other_process is make_process_from_name(
					os_data,program_selection,0
				). // run in window 0 without asking
				set child_process to other_process.
				set run_mode to "waiting_for_foreground".
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
				lw:add("Cancel").
				set child_process to run_menu(
					os_data,0,"Select window",lw,false
				).
				set run_mode to "window_selection".
			}
		}
	}
	else if run_mode="window_selection"{
		if process_finished(child_process){
			local window_selection is child_return.
			if window_selection="Background"{
				set window_selection to -1.
			}
			else if window_selection="Cancel"{
				set child_process to create_main_menu_child(process).
				set run_mode to "program_selection".
			}
			else{
				draw_empty_background(wnd).
				
				local other_process is make_process_from_name(
					os_data,program_selection,window_selection
				).

				if window_selection<>0{ // menu is still there
					local all_proc is get_process_list(os_data).
					all_proc:add(other_process).
					set child_process to create_main_menu_child(process).
					set run_mode to "program_selection".
				}
				else{ // menu must disappear to show program
					set child_process to other_process.
					set run_mode to "waiting_for_foreground".
				}
			}
		}
	}
	else if run_mode="waiting_for_foreground"{
		if process_finished(child_process){
			set wnd to get_process_window(process). //need to reset in
			// case child changed windows (i.e. window manager)
			draw_empty_background(wnd).
			set child_process to create_main_menu_child(process).
			set run_mode to "program_selection".
		}
	}

	if process[1]<>run_mode and run_mode="title_screen"{
		set process[2] to "ag9".//disable accidental double click by preventing click on first frame
		draw_empty_background(get_status_window(os_data)). //need to clean status after child
		invalidate_process_status(process). //redraw status on title
	}
	else if process[1]<>run_mode and run_mode="waiting_for_foreground"{
		draw_empty_background(get_status_window(os_data)).
	}

	// save
	set process[1] to run_mode.
	set process[3] to child_process.
	set process[4] to program_selection.
}
