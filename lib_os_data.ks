@lazyglobal off.

// os_data is a list of:
// [0] - window tree, represented as documented in main file
// [1] - list of all windows (simple list, not tree or what not)
// [2] - list of all processes
// [3] - currently focused window's index
// [4] - if true, enable focus mechanics
// [5] - list of installed programs, where each program is a list:
//    [0] - name of program
//    [1] - run program function
//    [2] - boolean stating whether it is system program
//          (runs always in window 0)
// [6] - status bar height (internal)
// [7] - window focus tip width (external)
// [8] - current highest process id
// [9] - list of all registered update functions

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
		0,terminal:height()-os_data[6]-3,
		terminal:width()-get_focus_tip_width(os_data)+1,os_data[6]+2
	).
}

function get_new_pid{
	parameter os_data.
	set os_data[8] to os_data[8]+1.
	return os_data[8].
}

function get_focus_tip_width{
	parameter os_data.
	return os_data[7].
}

function get_focus_tip_window{
	parameter os_data.
	local w is get_focus_tip_width(os_data).
	return make_rect(
		terminal:width()-w,terminal:height()-os_data[6]-3,
		w,os_data[6]+2
	).
}

function draw_status_bar{
	parameter os_data.
	draw_empty_window(get_status_window(os_data)).
	local tip is get_focus_tip_window(os_data).
	draw_empty_window(tip).
	local x is tip[0].
	local y is tip[1].
	print "Use 1/2" at(x+1,y+1).
	print "to move" at(x+1,y+2).
	print "focus. " at(x+1,y+3).
}

function new_os_data{
	return list(
		list(), // empty window tree
		list(), // empty window list
		list(), // empty processs list
		0,      // currently focused window
		true,   // show focus
		list(), // empty installed programs list
		3,      // status bar height - hardcoded to make unified experience
		9,      // ag1/ag2 tip width - hardcoded too
		-1,      // no processes exist yet
		list()
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

global __akros_invalid_update_function_index__error_message__ is "error: invalid update function index".

function register_update_function{ // to-do: add register_update_function to every job
	parameter
		os_data,
		update_function.
	local result is os_data[9]:length.
	os_data[9]:add(update_function).
	log "" to __akros_update_cache__.
	delete __akros_update_cache__.
	log "parameter process." to __akros_update_cache__.
	log "global __akros_update_result__ is 0." to __akros_update_cache__.
	log "if process<>0{" to __akros_update_cache__.
	log "local update_index is get_process_update_function_index(process)." to __akros_update_cache__.
	log "if false {}" to __akros_update_cache__. // I know it looks silly but it simplifies other things later
	local update_function_iter is os_data[9]:iterator.
	until not update_function_iter:next{
		log "else if update_index="+update_function_iter:index+"{global __akros_update_result__ is "+update_function_iter:value+"(process).}" to __akros_update_cache__.
	}
	log "else{print __akros_invalid_update_function_index__error_message__. print 1/0.}" to __akros_update_cache__.
	log "}" to __akros_update_cache__.
	run __akros_recompile_update_cache__.
	return result.
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
