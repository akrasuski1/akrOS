@lazyglobal off.

function open_window_manager{
	parameter os_data.

	local process is list(
		make_process_system_struct(
			get_window_list(os_data),"update_window_manager",0
		),
		os_data,ag6,ag7,ag8,ag9,ag10,get_window_tree(os_data):copy(),
		list(0),"x"
	).
	set os_data[0] to list("x").
	resize_windows(os_data).
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
}

function change_window_properties{
	parameter
		window_tree,
		current_window,
		fraction, //Change by selected amount
		division, //Change cyclically "x"->"v"->"h"->"x"
		cnt. //internal; call with 0
	
	if current_window[cnt]=0{
		//update THIS window
		if division{
			if window_tree[0]="x"{
				set window_tree[0] to "v".
				print "Y" at(50,50).
				until window_tree:length()>3{
					print window_tree:length at(50,51).
					window_tree:add(0.5).
				}
				print window_tree:length at(50,52).
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
		if current_window[cnt]=1{
			change_window_properties(window_tree[2],current_window,
				fraction,division,cnt+1).
		}
		else{
			change_window_properties(window_tree[3],current_window,
				fraction,division,cnt+1).
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
		log current_window:dump to "log2".
		if finished{
			resize_windows(os_data).
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
