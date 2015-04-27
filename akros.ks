run lib_window_akros_main_menu.
run lib_process.
run gui_programs.

// This is main file of akrOS, basic operating system developed by akrasuski1

set terminal:height to 60.
set terminal:width to 60.

set window_division to list(
	"v",0.5,list("x"),list(
		"h",0.5,list("x"),list("x")
	)
).
// each window is there represented as a list. If first element is 
// "x", then the window is not divided further. If it is "v"/"h",
// it is split vertically/horizontally into two other windows with ratio
// kept in the second field of the list. The last two fields represent 
// child windows recursively.

set list_of_windows to list().

function os_draw_divided_window{
	parameter 
		divided_window, // tree structure of windows
		window. // place and size
	
	if divided_window[0]="x"{
		draw_outline(window).
	}
	if divided_window[0]="v"{
		local first_window_share is round((window[2]-1)*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[2] to first_window_share.
		os_draw_divided_window(divided_window[2],wnd1).
		local wnd2 is wnd1:copy().
		set wnd2[0] to wnd1[0]+wnd1[2]-1.
		set wnd2[2] to window[2]-wnd1[0]-wnd1[2]+1.
		os_draw_divided_window(divided_window[3],wnd2).
	}
	if divided_window[0]="h"{
		local first_window_share is round((window[3]-1)*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[3] to first_window_share.
		os_draw_divided_window(divided_window[2],wnd1).
		local wnd2 is wnd1:copy().
		set wnd2[1] to wnd1[1]+wnd1[3]-1.
		set wnd2[3] to window[3]-wnd1[1]-wnd1[3]+1.
		os_draw_divided_window(divided_window[3],wnd2).
	}
}

function reset_window_list{
	parameter
		list_of_windows,
		divided_window,
		window,
		cnt.
	
	if divided_window[0]="x"{
		if list_of_windows:length()<=cnt{
			list_of_windows:add(window:copy()).
		}
		else{
			set list_of_windows[cnt] to window:copy().
		}
		return cnt+1.
	}
	if divided_window[0]="v"{
		local first_window_share is round((window[2]-1)*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[2] to first_window_share.
		reset_window_list(list_of_windows,divided_window[2],wnd1,cnt).
		local wnd2 is wnd1:copy().
		set wnd2[0] to wnd1[0]+wnd1[2]-1.
		set wnd2[2] to window[2]-wnd1[0]-wnd1[2]+1.
		reset_window_list(list_of_windows,divided_window[3],wnd2,cnt+1).
		return cnt+2.
	}
	if divided_window[0]="h"{
		local first_window_share is round((window[3]-1)*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[3] to first_window_share.
		reset_window_list(list_of_windows,divided_window[2],wnd1,cnt).
		local wnd2 is wnd1:copy().
		set wnd2[1] to wnd1[1]+wnd1[3]-1.
		set wnd2[3] to window[3]-wnd1[1]-wnd1[3]+1.
		reset_window_list(list_of_windows,divided_window[3],wnd2,cnt+1).
		return cnt+2.
	}
}

function resize_windows{
	clearscreen.
	set fraction to 0.5.//fraction of screen for left window
	local wnd is make_rect(0,0,terminal:width,terminal:height-2).
	os_draw_divided_window(window_division,wnd).
	reset_window_list(list_of_windows,window_division,wnd,0).

}

resize_windows().

set all_proc to list().
all_proc:add(open_window_akros_main_menu(list_of_windows,all_proc)).

set old_terminal_width to terminal:width.
set old_terminal_height to terminal:height.
until all_proc:length=0{
	update_all_processes(all_proc).
	if terminal:width<>old_terminal_width or
		terminal:height<>old_terminal_height{

		resize_windows().
		
		for proc in all_proc{
			invalidate_process_window(proc).
		}

		set old_terminal_width to terminal:width.
		set old_terminal_height to terminal:height.
	}
}

clearscreen.
