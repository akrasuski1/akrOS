@lazyglobal off.

parameter os_data.
global menu_update_function_index is register_update_function(os_data,"update_menu").

function run_menu{
	parameter
		os_data,
		window_index,
		title,
		list_of_names,
		return_index. // if true, returns index, otherwise value in list

	local current_option is 0.
	local len is list_of_names:length().

	local process is list(
		make_process_system_struct(
			os_data,menu_update_function_index,window_index,"Menu"
		),
		current_option,"ag7","ag8","ag9",list_of_names,title,
		return_index
	).
	return process.
}

function draw_menu_status{
	parameter process.

	if not has_focus(process){
		return 0.
	}

	local status is get_status_window(get_process_os_data(process)).
	local x is status[0].
	local y is status[1].

	print "AG7 - up" at (x+2,y+1).
	print "AG8 - down" at (x+2,y+2).
	print "AG9 - select" at (x+2,y+3).
	validate_process_status(process).
}

function draw_menu{
	parameter process.

	if not is_process_gui(process){
		return 0.
	}

	local window is get_process_window(process).
	local x is window[0].
	local y is window[1].
	local list_of_names is process[5].
	local len is process[5]:length().
	local title is process[6].
	local current_option is process[1].

	print title at(x+2,y+2).
	local i is 0.
	until i=len{
		print "[ ] "+list_of_names[i] at(x+2,y+i+4).
		set i to i+1.
	}
	//TODO: what if options dont fit on window? "[ ] Next page"
	print "*" at(x+3,y+4+current_option).
	validate_process_window(process).
}

function update_menu{
	parameter process.

	// restore state:
	local window is 0.
	local x is 0.
	local y is 0.
	if is_process_gui(process){
		set window to get_process_window(process).
		set x to window[0].
		set y to window[1].
	}
	local current_option is process[1].
	local list_of_names is process[5].
	local len is list_of_names:length().
	local return_index is process[7].
	// input:
	local old_ag7 is process[2].
	set process[2] to ag7.
	local changed_ag7 is old_ag7<>process[2].

	local old_ag8 is process[3].
	set process[3] to ag8.
	local changed_ag8 is old_ag8<>process[3].

	local old_ag9 is process[4].
	set process[4] to ag9.
	local changed_ag9 is old_ag9<>process[4].

	if old_ag7="ag7" or not has_focus(process){
		set changed_ag7 to false.
		set changed_ag8 to false.
		set changed_ag9 to false.
	}



	if process_needs_redraw(process){
		draw_menu(process).
	}
	if process_status_needs_redraw(process){
		draw_menu_status(process).
	}

	if changed_ag7{
		if is_process_gui(process){
			print " " at(x+3,y+4+current_option).
		}
		set current_option to mod(current_option-1+len,len).
		if is_process_gui(process){
			print "*" at(x+3,y+4+current_option).
		}
	}
	else if changed_ag8{
		if is_process_gui(process){
			print " " at(x+3,y+4+current_option).
		}
		set current_option to mod(current_option+1,len).
		if is_process_gui(process){
			print "*" at(x+3,y+4+current_option).
		}
	}
	else if changed_ag9{
		kill_process(process). // suicide
		if return_index{
			return current_option.
		}
		else{
			return list_of_names[current_option].
		}
	}

	// save:
	set process[1] to current_option.
}
