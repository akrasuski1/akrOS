@lazyglobal off.

run lib_window_vessel_stats.

function get_program_list{
	return list(
		"Vessel stats"
	).
}

function get_process_from_name{
	parameter
		program_name,
		list_of_windows,
		list_of_processes,
		selected_window_index.
	
	if program_name="Vessel stats"{
		return open_window_vessel_stats(
			list_of_windows[selected_window_index]
		).
	}
	else if program_name="qweqweqwe"{
		//etc.
	}
}
