@lazyglobal off.

// add to OS
parameter os_data.
register_program(os_data,"My widget title","run_my_widget",false).

function run_my_widget{
	parameter 
		os_data,
		window_index.
	
	local some_important_thing is 123.
	local process is list(
		make_process_system_struct(
			os_data,"update_my_widget",window_index,"My widget title"
		),
		"ag9",some_important_thing
	).
	return process.
}

function draw_my_widget_status{
	parameter process.

	if not has_focus(process){
		return 0.
	}
	
	local status is get_status_window(get_process_os_data(process)).
	local x is status[0].
	local y is status[1].
	local w is status[2].

	print "Type instructions here, such as:" at (x+2,y+2).
	print "Press 9 to quit." at (x+w-17,y+3).
	validate_process_status(process).
}

function draw_my_widget{
	parameter process.

	if not is_process_gui(process){
		return 0.
	}

	local window is get_process_window(process).
	local x is window[0].
	local y is window[1].
	local some_important_thing is process[2].
	
	print "Important thing is: "+some_important_thing at(x+2,y+2).
	validate_process_window(process).
}

function update_my_widget{
	parameter process.

	if process_needs_redraw(process){
		draw_my_widget(process).
	}
	if process_status_needs_redraw(process){
		draw_my_widget_status(process).
	}
	
	// restore:
	local some_important_thing is process[2].
	
	// input:
	local old_ag9 is process[1].
	set process[1] to ag9.
	local changed_ag9 is old_ag9<>process[1].

	if old_ag9="ag9" or not has_focus(process){
		set changed_ag9 to false.
	}

	if changed_ag9{
		kill_process(process). // quit when ready
		return 0.
	}

	if random()<0.5{
		set some_important_thing to some_important_thing+1.
		invalidate_process_window(process). // please, redraw me
	}
	
	// save state:
	set process[2] to some_important_thing.
}
