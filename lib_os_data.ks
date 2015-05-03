@lazyglobal off.

// os_data is a list of:
// [0] - window tree, represented as documented in main file
// [1] - list of all windows (simple list, not tree or what not)
// [2] - list of all processes
// [3] - currently focused window's index
// [4] - if true, visually show selected window
// [5] - list of installed programs, where each program is a list:
//    [0] - name of program
//    [1] - run program function
//    [2] - boolean stating whether it is system program 
//          (runs always in window 0)
// [6] - status bar height (internal)

// GET:
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

function get_status_height{
	parameter os_data.
	return os_data[6].
}

function get_status_window{
	parameter os_data.
	return make_rect(
		0,terminal:height()-os_data[6]-3,terminal:width(),os_data[6]+2
	).
}

function draw_status_bar{
	parameter os_data.
	draw_empty_window(get_status_window(os_data)).
}

function new_os_data{
	return list(
		list(), // empty window tree
		list(), // empty window list
		list(), // empty processs list
		0,      // currently focused window
		true,   // show focus
		list(), // empty installed programs list
		3       // status bar height - hardcoded to make unified experience
	).
}

function get_program_list{ // just names
	parameter os_data.

	local ret is list().
	for prog in os_data[5]{
		ret:add(prog[0]).
	}
	return ret.
}

function is_system_program{
	parameter
		os_data,
		program_name.
	
	for prog in os_data[5]{
		if prog[0]=program_name{
			return prog[2].
		}
	}
	print "No such program: "+program_name.
	local x is 1/0.
}

function make_process_from_name{
	parameter
		os_data,
		program_name,
		window_index.
	
	for prog in os_data[5]{
		if prog[0]=program_name{
			global __os_data is os_data.
			global __window_index is window_index.
			return evaluate(prog[1]+"(__os_data,__window_index)").
		}
	}
	print "No such program: "+program_name.
	local x is 1/0.
}


// SET:
function register_program{
	parameter
		os_data,
		program_name,
		program_run_function,
		is_system_program_bool.
	
	os_data[5]:add(list(
		program_name,program_run_function,is_system_program_bool
	)).
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
