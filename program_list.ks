@lazyglobal off.

// If you want to customize your akrOS, you can add more entries to this
// list or comment some of them to erase them.

function install_programs{
	parameter os_data.

	run job_vessel_stats(os_data).
	run job_window_manager(os_data).
}
