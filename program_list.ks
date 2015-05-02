@lazyglobal off.

run job_vessel_stats.

function get_program_list{
	return list(
		"Vessel stats",
		"Window manager"
	).
}

function make_process_from_name{
	parameter
		os_data,
		program_name,
		selected_window_index.
	
	if program_name="Vessel stats"{
		return run_vessel_stats(
			os_data,selected_window_index
		).
	}
	else if program_name="Window manager"{
		return run_window_manager(os_data). //it should run in 0 anyway
	}
	else if program_name="qweqweqwe"{
		//etc.
	}
}

function is_system_program{
	parameter program_name.
	return program_name="Window manager" or
		program_name="Settings".
	// system processes differ only in that they use always window 0
	// without asking
}
