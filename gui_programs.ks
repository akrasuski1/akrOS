@lazyglobal off.

run lib_window_vessel_stats.

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
		return open_window_vessel_stats(
			os_data,selected_window_index
		).
	}
	else if program_name="Window manager"{
		return open_window_manager(os_data). //it should run in 0 anyway
	}
	else if program_name="qweqweqwe"{
		//etc.
	}
}
