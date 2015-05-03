@lazyglobal off.

// Common includes:
print "Loading akrOS systems...".
run lib_exec.
print "Loaded lib_exec library.".
run lib_os_data.
print "Loaded OS data library.".
run lib_process.
print "Loaded process library.".
run lib_window.
print "Loaded window library.".
run job_menu.
print "Loaded menu library.".
run job_main_menu.
print "Loaded main menu library.".

// User defined programs:
run program_list.
print "Loaded user program list.".

// This is main file of akrOS, basic operating system developed by akrasuski1

// This function creates simple window list (like: [window1,window2,...])
// from recursively defined window tree.
function reset_window_list{
	parameter
		list_of_windows, // target window list
		divided_window,  // recursive window tree
		window.          // place on screen (rect)
	
	if divided_window[0]="x"{ // base case: simple, non-divided window
		list_of_windows:add(window:copy()).
	}
	if divided_window[0]="v"{ // window divided vertically
		local first_window_share is round(window[2]*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[2] to first_window_share.
		reset_window_list(list_of_windows,divided_window[2],wnd1).
		local wnd2 is wnd1:copy().
		set wnd2[0] to wnd1[0]+wnd1[2]-1.
		set wnd2[2] to window[2]-wnd1[2]+1.
		reset_window_list(list_of_windows,divided_window[3],wnd2).
	}
	if divided_window[0]="h"{ // window divided horizontally
		local first_window_share is round(window[3]*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[3] to first_window_share.
		reset_window_list(list_of_windows,divided_window[2],wnd1).
		local wnd2 is wnd1:copy().
		set wnd2[1] to wnd1[1]+wnd1[3]-1.
		set wnd2[3] to window[3]-wnd1[3]+1.
		reset_window_list(list_of_windows,divided_window[3],wnd2).
	}
}

// This function draws a normal border around window which has just lost
// focus, and a thick border around window which has gained it.
function update_focus{
	parameter
		os_data,
		shift_by.
	
	local current is get_focused_window(os_data).
	local old is current.
	set current to current+shift_by+get_window_list(os_data):length().
	set current to mod(current,get_window_list(os_data):length()).
	if old<>current and 
		get_showing_focused_window(os_data) and
		old<get_window_list(os_data):length(){

		local wnd is get_window_list(os_data)[get_focused_window(os_data)].
		draw_window_outline(wnd).
		draw_window_corners(wnd).
	}
	draw_status_bar(os_data).
	set_focused_window(os_data,current).
	if get_showing_focused_window(os_data){
		draw_focused_window_outline(
			get_window_list(os_data)[current]).
	}
	local i is 0.
	for wnd in get_window_list(os_data){
		draw_window_number(wnd,i).
		set i to i+1.
	}
	local focused_proc is 0.
	for proc in get_process_list(os_data){
		if has_focus(proc){
			set focused_proc to proc.
			break.
		}
	}
	if focused_proc<>0{
		invalidate_process_status(focused_proc).
	}
}

// This function redraws the whole system: windows, focused border, status
// and individual processes
//TODO: rename to redraw_everything
function resize_windows{
	parameter os_data.

	clearscreen.
	get_window_list(os_data):clear().
	reset_window_list(
		get_window_list(os_data),
		get_window_tree(os_data),
		make_rect(0,0,terminal:width,terminal:height-get_status_height(os_data)-2)
	).
	for wnd in get_window_list(os_data){
		draw_empty_window(wnd).
	}
	for wnd in get_window_list(os_data){
		draw_window_corners(wnd).
	}
	update_focus(os_data,0).
	for proc in get_process_list(os_data){
		invalidate_process_window(proc).
	}
}

// This function restores akrOS from previously saved data. This will
// revert processes, focus, and windows to the previous state.
// Unfortunately this function is of low use right now, due to kOS
// inability to serialize lists and save them to file.
function restore_akros{
	parameter os_data.

	local old_terminal_width is -1.
	local old_terminal_height is -1. //force redraw in the beginning
	local old_ag1 is ag1.
	local old_ag2 is ag2.
	local old_showing_focus is get_showing_focused_window(os_data).
	until get_process_list(os_data):length()=0{
		local change_focus is 0.
		if ag1<>old_ag1{
			set old_ag1 to ag1.
			set change_focus to change_focus-1.
		}
		if ag2<>old_ag2{
			set old_ag2 to ag2.
			set change_focus to change_focus+1.
		}
		local force_focus is false.
		if get_showing_focused_window(os_data)<>old_showing_focus{
			set old_showing_focus to get_showing_focused_window(os_data).
			set force_focus to true.
		}
		if change_focus<>0 or force_focus{
			update_focus(os_data,change_focus).
		}
		if terminal:width<>old_terminal_width or
			terminal:height<>old_terminal_height{

			resize_windows(os_data).

			set old_terminal_width to terminal:width.
			set old_terminal_height to terminal:height.
		}
		update_all_processes(get_process_list(os_data)).
	}
	clearscreen.//clean terminal when akrOS exits.
}

// This function is a wrapper around the previous function. It starts
// the akrOS with three windows (one on the left half of the screen
// and two on the right half). There are no processes running initially,
// other than the main menu.
function launch_akros{
	local window_tree is list( //this is just initial window tree - we need
		"v",0.5,list("x"),list( //something to start with. Maybe later
			"h",0.5,list("x"),list("x") // save a few of those as presets.
		)
	).
	// Each window is there represented as a list. If first element is 
	// "x", then the window is not divided further. If it is "v"/"h",
	// it is split vertically/horizontally into two other windows with ratio
	// kept in the second field of the list. The last two fields represent 
	// child windows recursively.

	local os_data is new_os_data().
	set os_data[0] to window_tree.
	
	print "Installing programs.".
	install_programs(os_data).
	print "Installed.".

	get_process_list(os_data):add(
		run_main_menu(os_data)
	).
	
	restore_akros(os_data).
}
