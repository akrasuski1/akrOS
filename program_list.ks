@lazyglobal off.

function install_programs{
	parameter os_data.

	run job_vessel_stats(os_data).
	run job_window_manager(os_data).
}
