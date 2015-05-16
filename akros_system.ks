@lazyglobal off.

clearscreen.
// Common includes:
print "Loading akrOS systems...".
print "Loading lib_exec library...".
run lib_exec.
print "Loading OS data library...".
run lib_os_data.
print "Loading process library...".
run lib_process.
print "Loading window library...".
run lib_window.

// User defined programs:
print "Loading user program list...".
run program_list.

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
	if not get_showing_focused_window(os_data){
		return 0.
	}
	set_focused_window(os_data,current).
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
	if focused_proc=0{ // empty window is focused
		draw_default_status_bar(os_data).
	}
	else{
		invalidate_process_status(focused_proc).
	}
	if get_showing_focused_window(os_data){
		draw_focused_window_outline(
			get_window_list(os_data)[current]).
	}
}

// This function redraws the whole system: windows, focused border, status
// and individual processes
function redraw_everything{
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
	local old_ag9 is ag9.
	local old_showing_focus is get_showing_focused_window(os_data).
	local all_proc is get_process_list(os_data).
	local frames_on_empty_window is 0.
	until get_os_quitting(os_data){
		local change_focus is 0.
		local open_main_menu is false.
		if ag1<>old_ag1{
			set old_ag1 to ag1.
			set change_focus to change_focus-1.
		}
		if ag2<>old_ag2{
			set old_ag2 to ag2.
			set change_focus to change_focus+1.
		}
		if ag9<>old_ag9{
			set old_ag9 to ag9.
			set open_main_menu to true.
		}
		local force_focus is false.
		if get_showing_focused_window(os_data)<>old_showing_focus{
			set old_showing_focus to get_showing_focused_window(os_data).
			set force_focus to true.
		}
		if change_focus<>0 or force_focus{
			if get_showing_focused_window(os_data){
				update_focus(os_data,change_focus).
			}
		}
		if terminal:width<>old_terminal_width or
			terminal:height<>old_terminal_height{

			redraw_everything(os_data).

			set old_terminal_width to terminal:width.
			set old_terminal_height to terminal:height.
		}
		
		if get_using_main_menu(os_data){
			if get_showing_focused_window(os_data){
				local focused_proc is 0.
				for proc in all_proc{
					if has_focus(proc){
						set focused_proc to proc.
						break.
					}
				}
				if focused_proc=0{
					set frames_on_empty_window to frames_on_empty_window+1.
				}
				else{
					set frames_on_empty_window to 0.
				}
			}
			else{
				set frames_on_empty_window to 0.
			}
			if open_main_menu and frames_on_empty_window>1{
				add_new_process(os_data,
					run_main_menu(os_data,get_focused_window(os_data))
				).
			}
		}
		update_all_processes(all_proc).
		for proc in get_new_processes(os_data){
			all_proc:insert(0,proc).
			if has_focus(proc){
				clear_status_window(os_data).
			}
		}
		get_new_processes(os_data):clear().
	}
	clearscreen. // clean terminal when akrOS exits.
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
	
	print "Installing programs...".
	install_programs(os_data).
	print "Done. Ready to launch now.".

	add_new_process(os_data,run_main_menu(os_data,0)).
	
	restore_akros(os_data).
}

// This function allows you to specify most of important things in akrOS
// during launch - window positions and size, and programs being ran.
// Still, programs will be ran from scratch (without any previous state)
// The second argument (program_list) is a list of two-element lists,
// first element of which is program name, and the second number of window
// it should be ran in.
// Note that main menu is not ran, unless specifically asked to.
function launch_akros_with_programs{
	parameter
		window_tree,
		program_list.
	
	local os_data is new_os_data().
	set os_data[0] to window_tree.

	print "Installing programs...".
	install_programs(os_data).
	print "Done. Ready to launch now.".
	
	local main_menu is false.
	for p in program_list{
		if p[0]="Main menu"{
			add_new_process(os_data,run_main_menu(os_data,p[1])).
			set main_menu to true.
		}
		else{
			add_new_process(os_data,make_process_from_name(os_data,p[0],p[1])).
		}
	}
	if not main_menu{
		set_using_main_menu(os_data,false).
	}

	restore_akros(os_data).
}
