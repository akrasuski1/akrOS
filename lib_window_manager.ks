@lazyglobal off.

function open_window_manager{
	parameter os_data.

	local process is list(
		make_process_system_struct(
			os_data,"update_window_manager",0,"Window manager"
		),
		os_data,ag6,ag7,ag8,ag9,ag10,get_window_tree(os_data):copy(),
		list(0),"x",0
	).
	set_showing_focused_window(os_data,false).
	set os_data[0] to list("x").
	resize_windows(os_data).
	local wl is get_window_list(os_data).
	set process[10] to wl[0].
	return process.
}

function draw_window_manager{
	parameter process.

	if not is_process_gui(process){
		return 0.
	}

	local window is get_process_window(process).

	print "akrOS Window Manager" at(window[0]+2,window[1]+2).
	print "0 - accept window" at(window[0]+2,window[1]+3).
	print "9 - cycle division" at(window[0]+2,window[1]+4).
	print "7/8 - div. ratio -/+" at(window[0]+2,window[1]+5).
	print "6 - revert and quit" at(window[0]+2,window[1]+6).

	//TODO mark current window somehow
	draw_window_manager_selection(
		get_window_tree(process[1]),
		process[10],process[8],0
	).
}

function draw_window_manager_selection{ //this ugly thing is pretty much
	parameter //copied from main file, with some changes. If any
		divided_window,//calculation details of window placement change,
		window,//this function would be outdated
		window_choice,
		depth. 
	
	if window_choice[depth]=0{
		draw_focused_window_outline(window).
	}
	else if divided_window[0]="v"{
		local first_window_share is round(window[2]*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[2] to first_window_share.
		if window_choice[depth]=1{
			draw_window_manager_selection(divided_window[2],
				wnd1,window_choice,depth+1).
		}
		else{
			local wnd2 is wnd1:copy().
			set wnd2[0] to wnd1[0]+wnd1[2]-1.
			set wnd2[2] to window[2]-wnd1[2]+1.
			draw_window_manager_selection(divided_window[3],
				wnd2,window_choice,depth+1).
		}
	}
	else if divided_window[0]="h"{
		local first_window_share is round(window[3]*divided_window[1]).
		local wnd1 is window:copy().
		set wnd1[3] to first_window_share.
		if window_choice[depth]=1{
			draw_window_manager_selection(divided_window[2],
				wnd1,window_choice,depth+1).
		}
		else{
			local wnd2 is wnd1:copy().
			set wnd2[1] to wnd1[1]+wnd1[3]-1.
			set wnd2[3] to window[3]-wnd1[3]+1.
			draw_window_manager_selection(divided_window[3],
				wnd2,window_choice,depth+1).
		}
	}
}

function change_window_properties{
	parameter
		window_tree,
		current_window,
		fraction, //Change by selected amount
		division, //Change cyclically "x"->"v"->"h"->"x"
		depth. //internal; call with 0
	
	if current_window[depth]=0{
		//update THIS window
		if division{
			if window_tree[0]="x"{
				set window_tree[0] to "v".
				until window_tree:length()>3{
					window_tree:add(0.5).
				}
				set window_tree[2] to list("x").
				set window_tree[3] to list("x").
			}
			else if window_tree[0]="v"{
				set window_tree[0] to "h".
			}
			else if window_tree[0]="h"{
				set window_tree[0] to "x".
			}
		}
		until window_tree:length()>1{
			window_tree:add(0.5).
		}
		set window_tree[1] to min(0.95,max(0.05,
			window_tree[1] + fraction)).
	}
	else{
		if current_window[depth]=1{
			change_window_properties(window_tree[2],current_window,
				fraction,division,depth+1).
		}
		else{
			change_window_properties(window_tree[3],current_window,
				fraction,division,depth+1).
		}
	}
}

function change_selected_window{
	parameter 
		current_window,
		div.
	
	if div="x"{
		local i is current_window:length()-1.
		until i<0{
			if current_window[i]<>1{
				current_window:remove(i).
			}
			else{
				break.
			}
			set i to i-1.
		}
		if i=-1{
			return true. //all done
		}
		set current_window[i] to 2.//it was one beforehands
		current_window:add(0).
		return false.
	}
	else{
		local index is current_window:length()-1.// due to kOS bug, need
		set current_window[index] to 1.//explicit index variable
		current_window:add(0).
		return false. //not finished
	}
}

function update_window_manager{
	parameter process.

	if process_needs_redraw(process){
		draw_window_manager(process).
	}
	
	local window is get_process_window(process).
	local os_data is process[1].
	local old_ag6 is process[2].
	local old_ag7 is process[3].
	local old_ag8 is process[4].
	local old_ag9 is process[5].
	local old_ag10 is process[6].
	local current_window is process[8].
	local div is process[9].
	// current window is list of choices in window tree leading to selected
	// window, for example (1,2,0) means left window, right window, this.
	
	local changed is false.
	if ag6<>old_ag6{
		set os_data[0] to process[7]. //revert to backupped tree
		resize_windows(os_data).
		kill_process(process).
		return 0.
	}
	if ag7<>old_ag7{
		//fraction change
		change_window_properties(get_window_tree(os_data),
			current_window,-0.05,false,0).
		invalidate_process_window(process).
		set process[3] to ag7.
		set changed to true.
	}
	if ag8<>old_ag8{
		//fraction change
		change_window_properties(get_window_tree(os_data),
			current_window,0.05,false,0).
		invalidate_process_window(process).
		set process[4] to ag8.
		set changed to true.
	}
	if ag9<>old_ag9{
		//change window division
		change_window_properties(get_window_tree(os_data),
			current_window,0,true,0).
		if div="x"{
			set process[9] to "v".
		}
		else if div="v"{
			set process[9] to "h".
		}
		else{
			set process[9] to "x".
		}
		set div to process[9].
		invalidate_process_window(process).
		set process[5] to ag9.
		set changed to true.
	}
	if ag10<>old_ag10{
		//change selected window
		local finished is change_selected_window(current_window,div).
		if finished{
			resize_windows(os_data).
			set_showing_focused_window(os_data,true).
			kill_process(process).
			return 0.
		}
		set process[9] to "x".//new div
		invalidate_process_window(process).
		set process[6] to ag10.
		set changed to true.
	}
	if changed{
		resize_windows(os_data).
	}
}
