@lazyglobal off.

// os_data is a list of:
// [0] - window tree, represented as documented in main file
// [1] - list of all windows (simple list, not tree or what not)
// [2] - list of all processes
// [3] - currently focused window's index
// [4] - if true, visually show selected window

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

function get_focused_window{
	parameter os_data.
	return os_data[3].
}

function get_showing_focused_window{
	parameter os_data.
	return os_data[4].
}


function set_focused_window{
	parameter
		os_data,
		foc.
	set os_data[3] to foc.
}

function set_showing_focused_window{
	parameter
		os_data,
		showing.
	set os_data[4] to showing.
}
