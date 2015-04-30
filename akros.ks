// Common includes:
run lib_os_data.
run lib_process.
run lib_window.
run lib_window_akros_main_menu.
run lib_window_menu.
run lib_window_manager.
run lib_exec.
// User defined programs:
run gui_programs.

// This is main file of akrOS, basic operating system developed by akrasuski1

set terminal:height to 90.
set terminal:width to 60.

function reset_window_list{
	parameter
		list_of_windows,
		divided_window,
		window.
	
	if divided_window[0]="x"{
		list_of_windows:add(window:copy()).
	}
	if divided_window[0]="v"{
		local first_window_share is round(window[2]*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[2] to first_window_share.
		reset_window_list(list_of_windows,divided_window[2],wnd1).
		local wnd2 is wnd1:copy().
		set wnd2[0] to wnd1[0]+wnd1[2]-1.
		set wnd2[2] to window[2]-wnd1[2]+1.
		reset_window_list(list_of_windows,divided_window[3],wnd2).
	}
	if divided_window[0]="h"{
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

function resize_windows{
	parameter os_data.

	clearscreen.
	get_window_list(os_data):clear().
	reset_window_list(
		get_window_list(os_data),
		get_window_tree(os_data),
		make_rect(0,0,terminal:width,terminal:height-2)
	).
	for wnd in get_window_list(os_data){
		draw_empty_window(wnd).
		log "asd" to "log1".
	}
	log get_window_list(os_data):dump() to "log1".
	log get_window_tree(os_data):dump() to "tree".
	for proc in get_process_list(os_data){
		invalidate_process_window(proc).
	}
}

set window_tree to list( //this is just initial window tree - we need
	"v",0.5,list("x"),list( //something to start with. Maybe later
		"h",0.5,list("x"),list("x") // save a few of those as presets.
	)
).
// each window is there represented as a list. If first element is 
// "x", then the window is not divided further. If it is "v"/"h",
// it is split vertically/horizontally into two other windows with ratio
// kept in the second field of the list. The last two fields represent 
// child windows recursively.

set os_data to list(window_tree,list(),list()).

get_process_list(os_data):add(
	open_window_akros_main_menu(os_data)
).

set old_terminal_width to -1.
set old_terminal_height to -1.
until get_process_list(os_data):length()=0{
	if terminal:width<>old_terminal_width or
		terminal:height<>old_terminal_height{

		resize_windows(os_data).

		set old_terminal_width to terminal:width.
		set old_terminal_height to terminal:height.
	}
	update_all_processes(get_process_list(os_data)).
}

clearscreen.
