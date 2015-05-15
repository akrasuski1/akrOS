@lazyglobal off.

// add to OS
parameter os_data.
register_program(os_data,"Resources","run_resources",false).

function run_resources{
	parameter 
		os_data,
		window_index.

	local process is list(
		make_process_system_struct(
			os_data,"update_resources",window_index,
			"Resources"
		),
		"ag9",time:seconds,ship:resources:length
	).
	return process.
}

function draw_resources_status{
	parameter process.

	if not has_focus(process){
		return 0.
	}
	
	local status is get_status_window(get_process_os_data(process)).
	local x is status[0].
	local y is status[1].
	local w is status[2].

	print "This window shows ship resources." at (x+2,y+2).
	print "Press 9 to quit." at (x+w-17,y+3).
	validate_process_status(process).
}

function draw_resources{
	parameter process.

	if not is_process_gui(process){
		return 0.
	}

	local window is get_process_window(process).
	local x is window[0]+2.
	local y is window[1].
	local xmax is x+window[2]-5.
	local last_len is process[3].
	
	if ship:resources:length<>last_len{
		draw_empty_background(window).
		set process[3] to ship:resources:length.
	}

	print "Resources:" at(x,y+2).
	set y to y+4.
	for res in ship:resources{
		local perc is round(res:amount/res:capacity*100).
		print res:name+": "+perc+"% " at(x,y).
		set y to y+1.
		print "[" at(x,y).
		print "]" at(xmax,y).
		local i is x+1.
		until i=xmax{
			if (i-x+1)/(xmax-x+1)<perc/100{
				print "|" at(i,y).
			}
			else{
				print " " at(i,y).
			}
			set i to i+1.
		}
		set y to y+2.
	}
	validate_process_window(process).
}

function update_resources{
	parameter process.

	if process_needs_redraw(process){
		draw_resources(process).
	}
	if process_status_needs_redraw(process){
		draw_resources_status(process).
	}
	
	// restore:

	local last_time is process[2].
	if time:seconds-last_time>5{
		// redraw every 5 game seconds
		invalidate_process_window(process).
		set process[2] to time:seconds.
	}

	// input:
	local old_ag9 is process[1].
	set process[1] to ag9.
	local changed_ag9 is old_ag9<>process[1].

	if old_ag9="ag9" or not has_focus(process){
		set changed_ag9 to false.
	}

	if changed_ag9{
		kill_process(process).
		return 0.
	}
}
