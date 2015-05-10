@lazyglobal off.

function run_number_dialog{
	parameter
		os_data,
		window_index,
		title,
		starting_number.
	
	local process is list(
		make_process_system_struct(
			os_data,"update_number_dialog",window_index,"Number dialog"
		),
		title,starting_number,"ag6","ag7","ag8","ag9","ag10","      ",1
	).
	return process.
}

function draw_number_dialog_status{
	parameter process.

	if not has_focus(process){
		return 0.
	}

	local status is get_status_window(get_process_os_data(process)).
	local x is status[0].
	local y is status[1].

	print "6/7 - number    -/+" at (x+2,y+1).
	print "8/9 - increment -/+" at (x+2,y+2).
	print "0   - enter" at (x+2,y+3).
	validate_process_status(process).
}

function draw_number_dialog{
	parameter process.

	if not is_process_gui(process){
		return 0.
	}

	local window is get_process_window(process).
	local x is window[0].
	local y is window[1].
	local title is process[1].
	local number is process[2].
	local spaces is process[8].
	local increment is process[9].
	
	print title at(x+2,y+2).
	print number+spaces at(x+2,y+4).
	print "-/+ "+increment+spaces at(x+2,y+6).
}

function update_number_dialog{
	parameter process.
	
	// restore:
	local title is process[1].
	local number is process[2].
	local spaces is process[8].
	local increment is process[9].
	// input:
	local old_ag6 is process[3].
	set process[3] to ag6.
	local changed_ag6 is old_ag6<>process[3].
	
	local old_ag7 is process[4].
	set process[4] to ag7.
	local changed_ag7 is old_ag7<>process[4].
	
	local old_ag8 is process[5].
	set process[5] to ag8.
	local changed_ag8 is old_ag8<>process[5].
	
	local old_ag9 is process[6].
	set process[6] to ag9.
	local changed_ag9 is old_ag9<>process[6].
	
	local old_ag10 is process[7].
	set process[7] to ag10.
	local changed_ag10 is old_ag10<>process[7].
	
	if old_ag6="ag6" or not has_focus(process){
		set changed_ag6 to false.
		set changed_ag7 to false.
		set changed_ag8 to false.
		set changed_ag9 to false.
		set changed_ag10 to false.
	}

	if process_needs_redraw(process){
		draw_number_dialog(process).
	}
	if process_status_needs_redraw(process){
		draw_number_dialog_status(process).
	}

	if changed_ag10{
		kill_process(process).
		return number.
	}
	if changed_ag6{
		set number to number - increment.
	}
	if changed_ag7{
		set number to number + increment.
	}
	if changed_ag8{
		set increment to increment / 10.
	}
	if changed_ag9{
		set increment to increment * 10.
	}

	if changed_ag6 or changed_ag7 or changed_ag8 or changed_ag9{
		invalidate_process_window(process).
	}

	// save state:
	set process[2] to number.
	set process[9] to increment.
}
