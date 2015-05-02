@lazyglobal off.

run lib_navball. // for compass

//add to OS
parameter os_data.
register_program(os_data,"Vessel stats","run_vessel_stats",false).

function run_vessel_stats{
	parameter 
		os_data,
		window_index.

	local process is list(
		make_process_system_struct(
			os_data,"update_vessel_stats",window_index,
			"Vessel stats"
		)
	).
	return process.
}

function draw_vessel_stats_status{
	parameter process.

	if not has_focus(process){
		return 0.
	}
	
	local status is get_status_window(get_process_os_data(process)).
	local x is status[0].
	local y is status[1].

	print "This window shows important vessel stats." at (x+2,y+2).
	validate_process_status(process).
}

function draw_vessel_stats{
	parameter process.

	if not is_process_gui(process){
		return 0.
	}

	local window is get_process_window(process).
	local x is window[0].
	local y is window[1].

	print "Vessel stats:" at(x+2,y+2).
	print "Latitude: "    at(x+2,y+4).
	print "Longitude: "   at(x+2,y+5).
	print "Compass: "     at(x+2,y+6).
	print "Mass: "        at(x+2,y+7).
	print "Name: "        at(x+2,y+8).
	print "Time: "        at(x+2,y+9).
	print "SAS: "         at(x+2,y+10).
	print "RCS: "         at(x+2,y+11).
	print "GEAR: "        at(x+2,y+12).
	print "LIGHTS: "      at(x+2,y+13).
	print "PANELS: "      at(x+2,y+14).
}

function bool_to_on_off{
	parameter bool.
	if bool{
		return "ON".
	}
	else{
		return "OFF".
	}
}

function update_vessel_stats{
	parameter process.

	if process_needs_redraw(process){
		draw_vessel_stats(process).
	}
	if process_status_needs_redraw(process){
		draw_vessel_stats_status(process).
	}
	if not is_process_gui(process){
		return 0. //no point of drawing stuff if I'm backgrounded
	}
	local wnd is get_process_window(process).
	local x is wnd[0].
	local y is wnd[1].

	print "FOCUS: "+has_focus(process)+" " at(wnd[0]+2,wnd[1]+16).

	print round(ship:geoposition:lat,5) at(x+12,y+4).
	print round(ship:geoposition:lng,5) at(x+13,y+5).
	print round(compass_for(ship),5)    at(x+11,y+6).
	print round(ship:mass,5)            at(x+8, y+7).
	print ship:name                     at(x+8, y+8).
	print time:clock                    at(x+8, y+9).
	print bool_to_on_off(sas)           at(x+7, y+10).
	print bool_to_on_off(rcs)           at(x+7, y+11).
	print bool_to_on_off(gear)          at(x+8, y+12).
	print bool_to_on_off(lights)        at(x+10,y+13).
	print bool_to_on_off(panels)        at(x+10,y+14).
}
