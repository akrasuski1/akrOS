@lazyglobal off.

// This file contains several useful graphic window drawing routines.
// It might seem as though a lot of code is duplicated - but it's done
// for performance reasons. Printing anything on screen is expensive
// in kOS, so each function is highly specialized and as optimized as
// reasonably possible.

// Internal representation of a window
function make_rect{
	parameter x,y,w,h.
	// w and h are EXTERNAL width and height
	return list(x,y,w,h). //returning list as a window handle
}

// This function draws window border and background (spaces)
function draw_empty_window{
	parameter rect.

	local x is rect[0].
	local y is rect[1].
	local w is rect[2].
	local h is rect[3].
	local top_str is "+".
	local middle_str is "|".
	local i is 0.
	until i>=w-2{
		set top_str to top_str+"=".
		set middle_str to middle_str+" ".
		set i to i+1.
	}
	set top_str to top_str+"+".
	set middle_str to middle_str+"|".
	print top_str at(x,y).
	print top_str at(x,y+h-1).
	set i to 1.
	until i>=h-1{
		print middle_str at(x,y+i).
		set i to i+1.
	}
}

// This function draws just the background (spaces)
function draw_empty_background{
	parameter rect.

	local x is rect[0].
	local y is rect[1].
	local w is rect[2].
	local h is rect[3].
	local middle_str is "".
	local i is 0.
	until i>=w-2{
		set middle_str to middle_str+" ".
		set i to i+1.
	}
	set middle_str to middle_str+"".
	set i to 1.
	until i>=h-1{
		print middle_str at(x+1,y+i).
		set i to i+1.
	}
}

// This is abstracted function used to draw window border using top_char
// as top and bottom border and side_char for sides.
function draw_any_outline{
	parameter
		rect,
		top_char,
		side_char.
	
	local x is rect[0].
	local y is rect[1].
	local w is rect[2].
	local h is rect[3].
	local top_str is "+".
	local i is 0.
	until i>=w-2{
		set top_str to top_str+top_char.
		set i to i+1.
	}
	set top_str to top_str+"+".
	print top_str at(x,y).
	print top_str at(x,y+h-1).
	set i to 1.
	until i>=h-1{
		print side_char at(x,y+i).
		print side_char at(x+w-1,y+i).
		set i to i+1.
	}
}

// Wrapper on draw_any_outline used to draw normal window border
function draw_window_outline{
	parameter rect.
	
	draw_any_outline(rect,"=","|").
}

// Wrapper on draw_any_outline used to draw focused window border
function draw_focused_window_outline{
	parameter rect.
	
	draw_any_outline(rect,"#","#").
}

// This function draws just window corners. It is needed because
// sometimes one window draws border on top of other window's corner
// leaving it in a slightly ugly state - corners are thus redrawn
// after all windows.
function draw_window_corners{
	parameter rect.

	local x is rect[0].
	local y is rect[1].
	local w is rect[2].
	local h is rect[3].
	print "+" at(x,y).
	print "+" at(x,y+h-1).
	print "+" at(x+w-1,y).
	print "+" at(x+w-1,y+h-1).
}

// As user needs to be aware of window numbers, they are drawn on the
// top border of each window.
function draw_window_number{
	parameter
		rect,
		number.

	print "["+number+"]" at(rect[0]+1,rect[1]).
}
