@lazyglobal off.

run lib_window.

function open_window_number_dialog{
	parameter window.
	parameter title.
	parameter number.
	
	local process is list(
		list(false, window, "update_window_number_dialog",false),
		title,number,ag6,ag7,ag8,ag9,ag10,"      ",1).
	draw_window_number_dialog(process).
	return process.
}

function draw_window_number_dialog{
	parameter process.

	if not is_process_gui(process){
		return.
	}

	local window is get_process_window(process).
	
	print "6/7 - number    -/+" at (window[0]+2, window[1]+5).
	print "8/9 - increment -/+" at (window[0]+2, window[1]+6).
	print "0   - enter" at (window[0]+2, window[1]+7).
}

function update_window_number_dialog{
	parameter process.

	local title is process[1].
	local window is get_process_window(process).
	local number is process[2].
	local old_decrease is process[3].
	local old_increase is process[4].
	local old_div10 is process[5].
	local old_mul10 is process[6].
	local old_enter is process[7].
	local spaces is process[8].
	local increment is process[9].
	
	if process_needs_redraw(process){
		draw_window_number_dialog(process).
	}

	if old_enter<>ag10{
		end_process(process).
		return number.
	}
	print title +" "+ number+spaces at(window[0]+2,window[1]+2).
	print "Increment: "+increment+spaces at(window[0]+2,window[1]+3).
	if old_decrease <> ag6{
		set process[3] to ag6.
		set process[2] to number - increment.
	}
	if old_increase <> ag7{
		set process[4] to ag7.
		set process[2] to number + increment.
	}
	if old_div10 <> ag8{
		set process[5] to ag8.
		set process[9] to increment / 10.
	}
	if old_mul10 <> ag9{
		set process[6] to ag9.
		set process[9] to increment * 10.
	}
}
