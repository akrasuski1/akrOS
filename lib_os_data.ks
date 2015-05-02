@lazyglobal off.

// os_data is a list of:
// [0] - window tree, represented as documented in main file
// [1] - list of all windows (simple list, not tree or what not)
// [2] - list of all processes
// [3] - currently focused window's index
// [4] - if true, visually show selected window
// [5] - list of installed programs:
//    [0] - list of names of programs
//    [1] - list of run program functions
//    [2] - list of booleans stating whether it is 
//          system program (runs always in window 0)
// [6] - status bar height (internal)

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
	return make_rect(0,terminal:height()-os_data[6]-3,terminal:width(),os_data[6]+2).
}

function draw_status_bar{
	parameter os_data.
	draw_empty_window(get_status_window(os_data)).
}

function new_os_data{
	return list(
		list(),
		list(),
		list(),
		0,
		true,
		list(list(),list(),list()),
		3
	).
}

function get_program_list{
	parameter os_data.
	return os_data[5][0]:copy().
}

function is_system_program{
	parameter
		os_data,
		program_name.
	
	local i is 0.
	local ip is get_program_list(os_data).
	until i = ip:length(){
		if ip[i]=program_name and os_data[5][2][i]=true{
			return true.
		}
		set i to i+1.
	}
	return false.
}

function make_process_from_name{
	parameter
		os_data,
		program_name,
		window_index.
	
	local i is 0.
	local ip is get_program_list(os_data).
	until i = ip:length(){
		if ip[i]=program_name{
			global __os_data is os_data.
			global __window_index is window_index.
			return evaluate(os_data[5][1][i]+"(__os_data,__window_index)").
		}
		set i to i+1.
	}
	print "No such program: "+program_name.
	local x is 1/0.
}

function register_program{
	parameter
		os_data,
		program_name,
		program_run_function,
		is_system_program_bool.
	
	os_data[5][0]:add(program_name).
	os_data[5][1]:add(program_run_function).
	os_data[5][2]:add(is_system_program_bool).
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
