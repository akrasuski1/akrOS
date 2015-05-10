@lazyglobal off.

// Process is a struct (list) containing process system info as its first
// element. Everything after that is process internal variables.
// System info:
// [0] - Process_finished (bool)
// [1] - os_data (list)
// [2] - Update_function (string)
// [3] - Please_redraw (bool)
// [4] - Index of process window (number) - if non-gui, invalid index (e.g. -1)
// [5] - Proces name (string)
// [6] - Please redraw status (bool)
// [7] - Process system id (number)

// GET:
function process_finished{
	parameter process.
	return process[0][0].
}

function get_process_window{
	parameter process.
	local wl is get_window_list(process[0][1]).
	return wl[process[0][4]].
}

function get_process_window_index{
	parameter process.
	return process[0][4].
}

function get_process_update_function{
	parameter process.
	return process[0][2].
}

function process_needs_redraw{
	parameter process.
	return process[0][3].
}

function is_process_gui{
	parameter process.
	return process[0][4]>=0 and 
		process[0][4]<get_window_list(process[0][1]):length.
}

function get_process_name{
	parameter process.
	return process[0][5].
}

function process_status_needs_redraw{
	parameter process.
	return process[0][6].
}

function has_focus{
	parameter process.
	return process[0][4]=get_focused_window(process[0][1]).
}

function get_process_os_data{
	parameter process.
	return process[0][1].
}

function get_process_id{
	parameter process.
	return process[0][7].
}

// SET:
function kill_process{
	parameter process.
	set process[0][0] to true.
}

function invalidate_process_window{
	parameter process.
	set process[0][3] to true.
}

function validate_process_window{
	parameter process.
	set process[0][3] to false.
}

function invalidate_process_status{
	parameter process.
	set process[0][6] to true.
}

function validate_process_status{
	parameter process.
	set process[0][6] to false.
}

function change_process_window{
	parameter
		process,
		index.

	set process[0][4] to index.
	invalidate_process_window(process).
}

function set_process_name{
	parameter
		process,
		name.
	set process[0][5] to name.
}

// OTHER:
function make_process_system_struct{
	parameter
		os_data,
		update_function,
		window_index,
		name.
	return list(
		false, // not finished yet
		os_data,
		update_function,
		true, // redraw needed
		window_index,
		name,
		true, // status redraw needed (check if has focus though!)
		get_new_pid(os_data)
	).
}

function update_process{
	parameter process.
	global __process_state is process.
	return evaluate(
		get_process_update_function(process)+"(__process_state)"
	).
	//TODO: update above line function pointers come.
}

function clean_after_process_killed{
	parameter proc.

	if is_process_gui(proc){
		draw_empty_background(get_process_window(proc)).
		if has_focus(proc){
			local os_data is get_process_os_data(proc).
			draw_default_status_bar(os_data).
		}
	}
}

function update_all_processes{
	parameter process_list.
	local i is 0.
	until i=process_list:length(){
		local proc is process_list[i].
		if process_finished(proc){
			clean_after_process_killed(proc).
			process_list:remove(i).
		}
		else{
			update_process(proc).
			if process_finished(proc){
				clean_after_process_killed(proc).
				process_list:remove(i).
			}
			else{
				set i to i+1.
			}
		}
	}
}
