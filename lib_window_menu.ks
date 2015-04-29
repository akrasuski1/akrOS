// This script shows a menu on the terminal allowing user to
// select one of the options and return it to calling script.
@lazyglobal off.

run lib_window.

function open_window_menu{
	parameter
		list_of_windows,
		window_index,
		title,
		list_of_names.

	local current_option is 0.
	local len is list_of_names:length().

	local last_up is ag7.
	local last_down is ag8.
	local last_sel is ag9.
	local process is list(
		make_process_system_struct(
			list_of_windows,"update_window_menu",window_index
		),
		current_option,last_up,last_down,last_sel,list_of_names,title
	).
	return process.
}

function draw_window_menu{
	parameter process.

	if not is_process_gui(process){
		return.
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
	print "7/8/9 - up/down/select" at(x+2,y+len+5).
	//TODO: what if options dont fit on window? Scroll!
	print "*" at(x+3,y+4+current_option).
	validate_process_window(process).
}

function update_window_menu{
	parameter process.

	local window is get_process_window(process).
	local x is window[0].
	local y is window[1].
	local current_option is process[1].
	local last_up is process[2].
	local last_down is process[3].
	local last_sel is process[4].
	local len is process[5]:length().
	
	if process_needs_redraw(process){
		draw_window_menu(process).
	}

	if ag7<>last_up{
		if is_process_gui(process){
			print " " at(x+3,y+4+current_option).
		}
		set current_option to mod(current_option-1+len,len).
		if is_process_gui(process){
			print "*" at(x+3,y+4+current_option).
		}
		set process[2] to ag7.
		set process[1] to current_option.
	}
	else if ag8<>last_down{
		if is_process_gui(process){
			print " " at(x+3,y+4+current_option).
		}
		set current_option to mod(current_option+1,len).
		if is_process_gui(process){
			print "*" at(x+3,y+4+current_option).
		}
		set process[3] to ag8.
		set process[1] to current_option.
	}
	else if ag9<>last_sel{
		end_process(process).
		return process[5][current_option].
	}
}
