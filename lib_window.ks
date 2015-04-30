

@lazyglobal off.

function make_rect{
	parameter x,y,w,h.
	// w and h are EXTERNAL width and height
	return list(x,y,w,h). //returning list as a window handle
}

function draw_filled_window{
	parameter
		rect,
		character.
	local x is rect[0].
	local y is rect[1].
	local w is rect[2].
	local h is rect[3].
	local eq_str is "+".
	local space_str is "|".
	local i is 0.
	until i>=w-2{
		set eq_str to eq_str+"=".
		set space_str to space_str+character.
		set i to i+1.
	}
	set eq_str to eq_str+"+".
	set space_str to space_str+"|".
	print eq_str at(x,y).
	print eq_str at(x,y+h-1).
	set i to 1.
	until i>=h-1{
		print space_str at(x,y+i).
		set i to i+1.
	}
}

function draw_empty_window{
	parameter rect.
	draw_filled_window(rect," ").
}
