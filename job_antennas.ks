@lazyglobal off.

run job_menu.

// add to OS
parameter os_data.
register_program(os_data,"Antennas","run_antennas",false).

function run_antennas{
	parameter
		os_data,
		window_index.

	local process is list(
		make_process_system_struct(
			os_data,"update_antennas",window_index,"Antennas"
		),
		"just_started", // run_mode
		"ag7",          // last ag7 state
		"ag8",          // last ag8 state
		"ag9",          // last ag9 state
		0,              // child process, if any. Otherwise 0.
		"antenna",      // selected antenna
		list()          // antenna list
	).
	if not addons:rt:available{
		kill_process(process).
	}
	return process.
}

function draw_antennas{
	parameter process.
	
	if not is_process_gui(process){
		return 0.
	}
	
	local run_mode is process[1].
	local child_process is process[5].
	if child_process<>0{ // pass redraw to child
		local window_index is get_process_window_index(process).
		change_process_window(child_process,window_index).
	}
	else if run_mode="selected_antenna"{ // redraw it yourself
		local window is get_process_window(process).
		local x is window[0].
		local y is window[1].

		local antenna is process[6].
		local module is antenna:getmodule("ModuleRTAntenna").
		local is_dish is module:hasfield("dish range").
		local range is "".
		if is_dish{
			set range to module:getfield("dish range").
			print "                " at(x+2,y+8).
			print "Target: " at(x+2,y+8). // temporary
		}
		else{
			set range to module:getfield("omni range").
		}

		print "Selected antenna:" at(x+2,y+2).
		print "Name: "+antenna:title at(x+2,y+4).
		print "Range: "+range+"    " at(x+2,y+5).
		print "Energy: "+module:getfield("energy")+"  " at(x+2,y+6).
		print          "             " at(x+10,y+7).
		print "STATUS: "+module:getfield("status") at(x+2,y+7).
	}
	validate_process_window(process).
}

function draw_antennas_status{
	parameter process.
	
	if not has_focus(process){
		return 0.
	}

	local run_mode is process[1].
	local child_process is process[5].
	if child_process<>0{ // pass redraw status event to child
		invalidate_process_status(child_process).
	}
	else if run_mode="selected_antenna"{ // redraw it yourself
		local status_bar is get_status_window(os_data).
		local x is status_bar[0].
		local y is status_bar[1].

		local antenna is process[6].
		local module is antenna:getmodule("ModuleRTAntenna").
		local is_dish is module:hasfield("dish range").
		if is_dish{
			print "Press 9 to toggle antenna." at(x+2,y+1).
			print "Press 8 to change target (doesn't work yet)." at(x+2,y+2).
			print "Press 7 to go back." at(x+2,y+3).
		}
		else{
			print "Press 9 to toggle antenna or 7 to go back." at(x+2,y+2).
		}
	}
	validate_process_status(process).
}

function update_antennas{
	parameter process.
	
	// restore state:
	local run_mode is process[1].
	local child_process is process[5].
	local antenna is process[6].
	local antenna_list is process[7].
	local os_data is get_process_os_data(process).
	local window_index is get_process_window_index(process).

	// input:
	local old_ag7 is process[2].
	set process[2] to ag7.
	local changed_ag7 is old_ag7<>process[2].

	local old_ag8 is process[3].
	set process[3] to ag8.
	local changed_ag8 is old_ag8<>process[3].

	local old_ag9 is process[4].
	set process[4] to ag9.
	local changed_ag9 is old_ag9<>process[4].

	if old_ag8="ag8" or not has_focus(process){
		set changed_ag7 to false.
		set changed_ag8 to false.
		set changed_ag9 to false.
	}
	

	if process_needs_redraw(process){
		draw_antennas(process).
	}
	if process_status_needs_redraw(process){
		draw_antennas_status(process).
	}
	
	local child_return is 0.
	if child_process<>0{ // update child if needed
		set child_return to update_process(child_process).
	}

	if run_mode="just_started"{
		local l1 is ship:modulesnamed("ModuleRTAntenna").
		set antenna_list to list().
		local choice_list is list().
		for module in l1{
			antenna_list:add(module:part).
			choice_list:add(module:part:title).
		}
		choice_list:add("Quit").
		set child_process to run_menu(
			os_data,
			window_index,
			"Antennas:",
			choice_list,
			true // return index
		).
		set run_mode to "selecting_antenna".
	}
	else if run_mode="selecting_antenna"{
		if process_finished(child_process){
			if child_return=antenna_list:length{
				kill_process(process).
				return 0.
			}
			set antenna to antenna_list[child_return].
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			invalidate_process_window(process).
			invalidate_process_status(process).
			set child_process to 0.
			set run_mode to "selected_antenna".
		}
	}
	else if run_mode="selected_antenna"{
		if changed_ag7{
			set run_mode to "just_started".
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
		}
		if changed_ag8{
			local module is antenna:getmodule("ModuleRTAntenna").
			local is_dish is module:hasfield("dish range").
			if is_dish{
				//TODO: do it when new kOS is finished
				print "Not implemented" at(1,1).
				invalidate_process_window(process).
			}
		}
		if changed_ag9{
			antenna:getmodule("ModuleRTAntenna"):doaction("toggle",true).
			invalidate_process_window(process).
		}
	}
	else{
		print "Invalid run_mode: "+run_mode. print 1/0.
	}

	// save
	set process[1] to run_mode.
	set process[5] to child_process.
	set process[6] to antenna.
	set process[7] to antenna_list.
}
