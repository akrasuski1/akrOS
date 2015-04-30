@lazyglobal off.

//process is a struct (list) containing process system info
//and, as a second element, process internal variables list.
//System info:
//[0] - Process_finished (bool)
//[1] - List_of_all_windows (list)
//[2] - Update_function (string)
//[3] - Please_redraw (bool)
//[4] - Index of my window (struct) - if non-gui, invalid index (e.g. -1)

//GET:
function process_finished{
	parameter process.
	return process[0][0].
}

function get_process_window{
	parameter process.
	return process[0][1][process[0][4]].
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
	return process[0][4]>=0 and process[0][4]<process[0][1]:length.
}


//SET:
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

function change_process_window{
	parameter
		process,
		index.

	set process[0][4] to index.
	invalidate_process_window(process).
}

//OTHER:
function make_process_system_struct{
	parameter
		list_of_windows,
		update_function,
		window_index.
	return list(
		false, // not finished yet
		list_of_windows,
		update_function,
		true, // redraw needed
		window_index
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

function update_all_processes{
	parameter process_list.
	local i is 0.
	until i=process_list:length(){
		local proc is process_list[i].
		if process_finished(proc){
			process_list:remove(i).
			if is_process_gui(proc){
				draw_empty_window(get_process_window(proc)).
			}
		}
		else{
			update_process(proc).
			set i to i+1.
		}
	}
}
