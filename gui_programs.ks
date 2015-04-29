@lazyglobal off.

run lib_window_vessel_stats.

function get_program_list{
	return list(
		"Vessel stats"
	).
}

function make_process_from_name{
	parameter
		os_data,
		program_name,
		selected_window_index.
	
	if program_name="Vessel stats"{
		return open_window_vessel_stats(
			get_window_list(os_data),selected_window_index
		).
	}
	else if program_name="qweqweqwe"{
		//etc.
	}
}
