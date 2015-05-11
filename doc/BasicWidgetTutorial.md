# Basic widget tutorial

akrOS - simple operating system made in kOS is made of modular parts called *widgets*. 
These are separate programs that run in one particular window at a time (or not - they may
run in background).
They are of highest interest for other developers, as they allow you to create 
specific programs suitable for specific cases - for example rover control.
As a matter of convention, all widgets are saved in separate files, called
`job_somename`, for example `job_vessel_stats`. The only other place you will
have to edit in order to make your widget available in akrOS, is `program_list.ks`. The instructions
about it are contained in that file itself, so I won't discuss it here.

## Basic widget structure

The very skeleton of a widget (that is fully functional) is available in `job_widget_skeleton.ks`.
Let's skim over the main parts it contains.


#### Header
```
@lazyglobal off.

// add to OS
parameter os_data.
register_program(os_data,"My widget title","run_my_widget",false).
```

These are the first lines of widget ddefinition. It is very useful to add `@lazyglobal off.`
directive here, because it forces you to always specify whether your variables are local or
global. In most widgets, variables should be **local**.

The following two lines add your widget to the akrOS. The `register_program` function accepts
four parameters:
* os_data - don't think about it much - it is simply a reference to akrOS internal storage,
that will allow the function to know where the program definition needs to be stored. You
will get `os_data` as parameter.
* widget title - string that contains name of your program, for example "Vessel stats".
* name of widget creation function - for now, due to kOS limitations, this has to be a string.
A convention that I adopted is that the function has name `run_somename`, for example 
`run_vessel_stats`.
* is it system program - this is in most cases false. Currently the only difference between
normal and system programs is that the latter don't ask in which window they will be created,
but choose it itself. Not recommended, especially as a first widget.

#### `run` function

```
function run_my_widget{
	parameter 
		os_data,
		window_index.
	
	local some_important_thing is 123. // This is example. Not needed in real code.
	local process is list(
		make_process_system_struct(
			os_data,"update_my_widget",window_index,"My widget title"
		),
		"ag9",some_important_thing
	).
	return process.
}
```

This function is responsible for widget creation. It **has** to accept exactly two arguments:
* os_data
* window_index - number of window, where this widget is to be created

You may do some calculation in this function, but it is not recommended, as you do not have
any window yet, so you cannot display your results anyway.

The function has to return a *process*. Process is a kOS structure containing:
* system data, which you don't have to care about
* user data, which are important for this widget

The usual way process structure is constructed and then returned is shown in above code.
You create a `list` of a few elements, first of which is the system structure, and the rest
(indexes 1, 2, 3, ...) are yours. In the above example, data you want to remember between 
consecutive updates is initially string "ag9" and number 123 contained in `some_important_thing`.

As you may have noticed, I use a helper function in order to create the aforementioned system
structure. The function's name is `make_process_system_struct` and it accepts four arguments:
* os_data
* update function name - again, as a string
* your window index
* title of your widget

All of those arguments were described earlier, so I don't think I need to repeat.

#### `draw status` function

```
function draw_my_widget_status{
	parameter process.

	if not has_focus(process){
		return 0.
	}
	
	local status is get_status_window(get_process_os_data(process)).
	local x is status[0].
	local y is status[1].
	local w is status[2].

	print "Type instructions here, such as:" at (x+2,y+2).
	print "Press 9 to quit." at (x+w-17,y+3).
	validate_process_status(process).
}
```

This is the next function in the basic widget skeleton. It is used to draw in the *status bar* - a
small rectangular box in the bottom of the terminal. You may use it for your purposes, but the best
thing you can put there, are instructions about your widget - in particular, which action groups
do which things. This function has no enforced definition (number of arguments, name, etc.), but it 
is very helpful if we all follow one convention - call the function `draw_somename_status`, and make
it accept one argument - the process structure.

The first thing this process should do, is check whether the widget process has *focus* - that is, if
the window around the widget has thick border (You can change focus using AG1 and AG2). Only focused
windows are allowed to draw their status, so if the check is absent, two windows will draw their status
at the same time, leading to blinking and useless, unreadable status. So keep the check here.

Then, provided you have focus, you should get available area, where you can draw your status. The way
to do this is presented above: `get_status_window(get_process_os_data(process)).`. This function returns
a *window* - a structure containing four elements, in the following order: x-coordinate of left edge,
y-coordinate of top edge, width and height. The next three lines get x, y and w from that structure,
to make following code less complex.

Then, you can draw whatever you want in the provided box. Be aware that status bar is only three lines
wide, so you should be concise in whatever you type there. Also, I encourage you to test your code often,
as it is very easy to make off-by-one mistakes here.

The last line of this function should always be `validate_process_status(process).`. This tells
the OS, that a status redraw is no longer needed for this window. If you forget this line, the OS might
become slower, because it will redraw the status even when not needed.

#### `draw` function

```
function draw_my_widget{
	parameter process.

	if not is_process_gui(process){
		return 0.
	}

	local window is get_process_window(process).
	local x is window[0].
	local y is window[1].
	local some_important_thing is process[2].
	
	print "Important thing is: "+some_important_thing at(x+2,y+2).
	validate_process_window(process).
}
```

The third function is used for general redraw of the widget window. Since this is just an example
widget, I just display our `some_important_thing` here. A real widget might want to draw some stats here,
for example current apoapsis and such things.

Again, this function does not have enforced definition, but a general convention is that it should be called
`draw_somename` and accept one argument - process structure. 

The first thing the function should check, is whether the program even *has* its window. Since widgets can
be ran in background (without window display), trying to draw while in background may and usually causes 
akrOS crash. So, the safety check should be the first thing we do - we use a `is_process_gui` function, which
tells if the process has a window.

Provided that the check was succesful, we can get our window. This is made using function
`get_process_window(process)`. This returns window structure, similar to that of status bar (x, y, w and h).
Then we get two first fields from that window (upper left corner coordinates) and restore data from
user data saved in process structure. Remember the first function from this tutorial? We saved
`some_important_thing` at the second place in process structure, so now we can get it using `process[2]`.

Finally, we can move to drawing. Note that we can't draw at absolute coordinates, such as `at(23,48)`, 
because they will change every time widget is created. Instead, use relative coordinates, such as
`at(x+2,y+15)`.

The last line in this function should always be `validate_process_window(process).`. This makes OS know
that the redraw is no longer needed. If you forget about this line, you may cause akrOS to run slowly and
the window to be flickering rapidly. So don't forget about it.

#### `update` function

This is the most important function of them all. Since it is a bit longer than the rest, I will divide
the explanation into two parts. First:

```
function update_my_widget{
	parameter process.

	if process_needs_redraw(process){
		draw_my_widget(process).
	}
	if process_status_needs_redraw(process){
		draw_my_widget_status(process).
	}
	
	// restore:
	local some_important_thing is process[2].
	
	// input:
	local old_ag9 is process[1].
	set process[1] to ag9.
	local changed_ag9 is old_ag9<>process[1].

	if old_ag9="ag9" or not has_focus(process){
		set changed_ag9 to false.
	}
	
	...
```

This function is your main update function. Whatever you type here, will be repeated a couple of times
per second by the akrOS. Treat it as though the whole code was inside a huge `until false` block.

Since this function is called directly by the akrOS, it has to follow exact definition. It needs to accept 
exactly one parameter - the process structure. By convention, it should be called `update_somename` and should
match the function name you passed to process constructor in the first function.

The first things the update function should do, is check whether the window or status need to be redrawn, and
do it if needed. Thankfully, we have functions that do it for us, which make it simple. Just paste those six
lines of code into your widget and you'll be fine. `process_needs_redraw` and `process_status_needs_redraw` are
both functions provided by akrOS.

The next step is to restore values you will need in the update function. Technically, you could refer to them
as `process[2]` etc. everywhere, but it's very easy to mistake index there. If you use restore in the beginning
of the function only, you minimize chance for error.

The next step after restoring state of the "loop", is processing user input, if you need. In this case, we want
our widget to close when you press AG9. Since our OS has focus mechanics, you can't just do `when ag9`, because
this would ignore focus and make your widget respond to user input even if other user is concentrating on 
another window (wants to choose something from the menu, for example).

To reduce race conditions (action groups changing between game updates), you should read former state of action
group from process structure, and immediately after that, write the current one. The result - did the user
press the action group? - is stored in `changed_ag9` as `old_ag9<>processs[1]`, wherer `process[1]` is the new 
AG9 state.

You can add more action groups in the similar way, using these three lines for each action group. You need to
remember however, that you still need to check two things afterwards, but still before making use of user input.
`if old_ag9="ag9" or not has_focus(process)` - the last condition checks whether your window has focus or 
not - if not, you can't process user input. The first condition is more delicate - when you run your program 
via AG9 from main menu, the AG9 change can still come to your program under some conditions. This check makes
sure you don't process user input during your very first update.

Second part of the `update` function:
```
	...
	
	if changed_ag9{
		kill_process(process). // quit when ready
		return 0.
	}

	if random()<0.5{
		set some_important_thing to some_important_thing+1.
		invalidate_process_window(process). // please, redraw me
	}
	
	// save state:
	set process[2] to some_important_thing.
}
```

Finally, we are done with micromanagement of stored data and processing user input. Now, we can actually do
stuff. Since I told you that AG9 will close the widget, here it is, in a very clean check. Inside the `if` body,
we use `kill_process` function. This is another example of akrOS system functions - one, that pretty much every
widget should somehow make use of. Whether by action group, or via some end condition (such as apoapsis>100000),
every widget should end somehow. As a best practice, directly after that call, you should put `return 0.` - this
will skip the rest of the body of the process, so that you don't waste precious kOS instructions.

Then, provided we haven't finished yet, we may do our stuff. In this trivial widget example, I will simply
increment the `some_important_thing` variable with probability 1/2. If it is incremented, we know that the number
on the screen is no longer valid, so we need to `invalidate_process_window(processs).`, which, as code comment
says, means just that in the next update you should redraw the screen.

Finally, you should save state of the process. Do it just the same way as in the beginning of this function, just
this time set `process[2]` etc. and not the variables. See above for the example.

#### `program_list.ks`

Don't forget to add your newly created widget to `program_list.ks` file. Otherwise you won't be able to select
it from the main menu. The added linee  in that file should look like this: `run job_widget_skeleton(os_data).`
