@lazyglobal off.

// os_data is a list of:
// [0] - window tree, represented as documented in main file
// [1] - list of all windows (simple list, not tree or what not)
// [2] - list of all processes

function get_window_tree{
	parameter os_data.
	return os_data[0].
}

function get_window_list{
	parameter os_data.
	return os_data[1].
}

function get_process_list{
	parameter os_data.
	return os_data[2].
}
