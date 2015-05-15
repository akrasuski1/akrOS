# Advanced widget tutorial

In this tutorial, I will introduce a couple of new concepts, using an example of calculator widget. We will want
to prompt user for the first number, then operation (one of: +, -, *, /, ^), then seond number, and finally display
calculated result. Simple enough. If you were doing it "normal" way - without akrOS - the code would look somewhat
like this:
```
local num1 is prompt_for_number().
local op is prompt_for_option(list("+","-","*","/","^")).
local num2 is prompt_for_number().
local result is calculate(num1,op,num2).
print "The result is "+result.
```

I hope you understand the above code, since it will be the basis for further discussion. Don't worry about all the
functions right now - they are just abstractions, keeping the code simple.

## Run modes

The above code contains a couple of process states: waiting for first number, waiting for operator, waiting
for second number, displaying result. The akrOS processes are ran in an infinite loop, so we need to somehow
differentiate between them. The easiest way to do this, is by using *run modes* - variable, usually string one,
denoting current state. So the update function would look like:
```
if run_mode="input_first_number"{
	set num1 to prompt_for_number().
	set run_mode to "input_operator".
}
else if run_mode="input_operator"{
	set operator to prompt_for_option("+","-","*","/","^").
	set run_mode to "input_second_number".
}
else if
	...
```
and so on. The code might look broken - only one `if` will be fulfilled at any time, and even if `run_mode` is
changed, the next `if` won't be ran. But recall that the above code is ran in a loop, so in the next iteration,
that next `if` will be ran, so there will be no problems with that. Just remember to restore `run_mode` from 
process structure in the beginning of the update function and save it for later in the end of it.

## Child processes

Since the whole widget code in akrOS is always ran in an update loop, we cannot simply use the above code, because
it would hang the whole system until you finally choose an option - so that your, for example, auto-pilot won't be
able to keep your plane upright while you input your numbers. We need to do something different.

akrOS omes with a couple of simple utility widgets. One of them is `job_number_dialog`, and the other `job_menu`.
First of them prompts user for a number, and the second one for a choice from the list. They are processes like
any other widget, with just one difference - they accept some more arguments in their constructor, so they
cannot be ran from the main menu - running number dialog from main menu would be nonsense - what would the input 
number mean, after all?

So, we can use number dialog as a first part of our program. It should be ran as a *child process*. In order
to do this, you should remember child process' structure as one of the fields in your own process, for example
as `process[1]`. In the very first frame, you should create that child process, for example: 
`set child_process to run_number_dialog(os_data,window_index,"Input number:",0).`

Note that this way, akrOS will not "know" about the child process directly. Thus, you will have to update the child
on your own. Don't worry though, it's pretty simple. All you need to do, is type: `set child_return to
update_process(child_process).` and that's it. If you don't need the returned value, you can even skip the first
three words as well.

One more thing you should take care of, is redrawing of the child window and status. In order to do this, you 
should pass redraw event to child whenever necessary. This may sound enigmatically, but it's quite simple as well.
In your draw function, type the following line to be run whenever you have a child process:
`change_process_window(child_process,window_index).` I know this may sound weird, but believe me - that is exactly
the line you need to type. There is alsso a function called `invalidate_process_window`, but it is not recommended
in this case, because if your parent process is moved to another window via process manager, your child will be
ignorant about this change. The recommended line takes care about this situation by always passing current window
to the child redraw function. 

Children status update is done via a similar line in your status draw function:
`invalidate_process_status(child_process).` Note that you do not need to pass any windows and such to child, as
status bar is common to all windows in the system.

## Example - calculator

I believe that this introduction prepared you to face the first advanced widget - it will be a calculator. The full code is available in `job_calculator.ks` file - I will describe all the parts of it below.

#### Header

```
@lazyglobal off.

run job_number_dialog.
run job_menu.

// add to OS
parameter os_data.
register_program(os_data,"Calculator","run_calculator",false).
```

It is very similar to what you saw in basic widget tutorial. Note that we will need number dialog, which is not
included with standard akrOS package, so we need to include it here via `run job_number_dialog.` Same applies to
`job_menu`.

#### `run` function

```
function run_calculator{
	parameter
		os_data,
		window_index.

	local process is list(
		make_process_system_struct(
			os_data,"update_calculator",window_index,"Calculator"
		),
		"just_started", // run_mode
		"ag8",          // last ag8 state
		"ag9",          // last ag9 state
		0,              // child process, if any. Otherwise 0.
		0,              // first number
		"+",            // operator
		0,              // second number
		0               // result of the operation
	).
	return process.
}
```

Again, I don't think much explanation is needed here, because all the things here are looking very similar to 
what you learned in basic tutorial. Note that since this is a more advanced widget, we will need to remember
much more information in the process data. All the fields are commented, so that you may understand their purpose
at the first sight.

#### `draw` function

```
function draw_calculator{
	parameter process.
	
	if not is_process_gui(process){
		return 0.
	}
	
	local run_mode is process[1].
	local child_process is process[4].
	if child_process<>0{ // pass redraw to child
		local window_index is get_process_window_index(process).
		change_process_window(child_process,window_index).
	}
	...
```

This is the first part of the draw function. First we check whether we have any window - if not, there is no point
in redrawing, so we instantly return from the  function.

Then, we restore some data from process structure. Then, there is an important check whether we are having a 
child process running, or we are updating the screen ourselves. If we have a child (`child_process<>0`), we need
to tell the child to redraw its window (`change_process_window(child_process,window_index).`).

```
	if child_process<>0{ // pass redraw to child
		...
	}
	else if run_mode="display_result"{ // redraw it yourself
		local window is get_process_window(process).
		local x is window[0].
		local y is window[1].

		local first_number is process[5].
		local operator is process[6].
		local second_number is process[7].
		local result is process[8].

		print first_number+operator+second_number+"="+result at(x+2,y+2).
	}
	validate_process_window(process).
}
```

Otherwise, we need to update the screen ourselves. If current `run_mode` (more about them later) is 
"display_result", then we will, as name suggests, display the result. We get process window (we already checked
that a window exists earlier), and then restore some process variables. Finally, we can print whatever we want -
in this case, we print first number, operator, second number, equal sign and result, for example `2+2=4`.

The last line validates the window - tells the system that the window no longer requires a window redraw.

#### `draw status` function

```
function draw_calculator_status{
	parameter process.
	
	if not has_focus(process){
		return 0.
	}

	local run_mode is process[1].
	local child_process is process[4].
	if child_process<>0{ // pass redraw status event to child
		invalidate_process_status(child_process).
	}
	...
```

First we check whether our window is focused - if not, we should not be drawing status in the first place, so we
return from the function. The next thing is to restore some variables. If we have a child, we should pass a 
status redraw event to that child by `invalidate_process_status(child_process).`

```
	if child_process<>0{ // pass redraw status event to child
		...
	}
	else if run_mode="display_result"{ // redraw it yourself
		local status_bar is get_status_window(os_data).
		local x is status_bar[0].
		local y is status_bar[1].

		print "Press 9 to close or 8 to restart." at(x+2,y+2).
	}
	validate_process_status(process).
}
```

Otherwise, we take care of status drawing ourselves. We get status bar window from the OS. Then we print some
instructions at relative coordinates: `at(x+2,y+2)`. Finally, we validate our process' status, so that the
OS knows the status redraw is no longer needed.

#### `update` function

```
function update_calculator{
	parameter process.
	
	// restore state:
	local run_mode is process[1].
	local child_process is process[4].
	local first_number is process[5].
	local operator is process[6].
	local second_number is process[7].
	local result is process[8].
	local os_data is get_process_os_data(process).
	local window_index is get_process_window_index(process).
```

All those lines a responsible for restoring process data.

```
	// input:
	local old_ag8 is process[2].
	set process[2] to ag8.
	local changed_ag8 is old_ag8<>process[2].

	local old_ag9 is process[3].
	set process[3] to ag9.
	local changed_ag9 is old_ag9<>process[3].

	if old_ag8="ag8" or not has_focus(process){
		set changed_ag8 to false.
		set changed_ag9 to false.
	}
```

We get user input in the same way as in the basic tutorial. Remember that we always need to check whether we have
focus right now - otherwise you would respond to other windows' input!

```
	if process_needs_redraw(process){
		draw_calculator(process).
	}
	if process_status_needs_redraw(process){
		draw_calculator_status(process).
	}
```

Taking care of redrawing window and status bar.

```
	local child_return is 0.
	if child_process<>0{ // update child if needed
		set child_return to update_process(child_process).
	}
```

Updating child process if needed. Since we will need its return value, we save it in a local variable.

```
	if run_mode="just_started"{
		set child_process to run_number_dialog(
			os_data,
			window_index,
			"First number:",
			0
		).
		set run_mode to "input_first_number".
	}
```

The huge `if` block begins here. If our `run_mode` is "just_started", that means it is our very first frame,
so we will have to create a number dialog. The parameters for that widget are as follows:
* os_data
* window_index
* title text
* initial number, here 0

Then, we need to set our `run_mode` to "input_first_number", since that is the thing we will be doing next.

```
	else if run_mode="input_first_number"{
		if process_finished(child_process){
			set first_number to child_return.
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			set child_process to run_menu(
				os_data,
				window_index,
				"Operator: ["+first_number+"_]",
				list("+","-","*","/","^"),
				false
			).
			set run_mode to "input_operator".
		}
	}
```

If we are at the next step, we want the user to input a number. If our child process has finished, that means
the user did just that. So we can set `first_number` variable to a value our child has returned earlier. Since
we will then spawn a new child, we need to clean screen first. We do it through `draw_empty_background` and
`draw_status_bar` functions. Since our process could technically be backgrounded (useless, but we have to prepare
for that), we need to wrap these two lines in an `if is_process_gui(process)` block.

Then, we can spawn a new child. This time, we won't be inputting a number, but rather an operator. The easiest
way to do this is by using a menu widget. It accepts the following arguments:
* os_data
* window_index
* title text
* list of available options
* boolean stating whether the process should return an index of the chosen value, or that value itself. In most
cases you want this to be false (return the value itself)

Then we just set `run_mode` to "input_operator".

```
	else if run_mode="input_operator"{
		if process_finished(child_process){
			set operator to child_return.
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			set child_process to run_number_dialog(
				os_data,
				window_index,
				"Second number: ["+first_number+operator+"_]",
				0
			).
			set run_mode to "input_second_number".
		}
	}
```

This is a very similar block to the previous one. Refer to its explanation.

```
	else if run_mode="input_second_number"{
		if process_finished(child_process){
			set second_number to child_return.
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			set child_process to 0. // no process
			set run_mode to "display_result".
			if operator="+"{
				set result to first_number+second_number.
			}
			else if operator="-"{
				set result to first_number-second_number.
			}
			else if operator="*"{
				set result to first_number*second_number.
			}
			else if operator="/"{
				if abs(second_number)>0{
					set result to first_number/second_number.
				}
				else{
					set result to "Error".
				}
			}
			else if operator="^"{
				if first_number<0
					and abs(second_number-round(second_number,0))>0{
					set result to "Error".
				}
				else{
					set result to first_number^second_number.
				}
			}
			invalidate_process_window(process). // print result
			invalidate_process_status(process). // print status
		}
	}
```

Finally, we have gathered all the data we need from the user. We can erase the child process (`set child_process
to 0.`). Then, we calculate the result of the operation - this is what a calculator does, after all (we check
for a couple of special cases too, such as division by zero). We will want to display the variable afterwards, 
so we invalidate our process' window. Status is cleaned as well, because in our own display, we will use the
status ourselves.

```
	else if run_mode="display_result"{
		if changed_ag8{
			if is_process_gui(process){
				draw_empty_background(get_process_window(process)).
				draw_status_bar(os_data).
			}
			set child_process to run_number_dialog(
				os_data,
				window_index,
				"Input first number:",
				0
			).
			set run_mode to "input_first_number".
		}
		if changed_ag9{
			kill_process(process).
			return 0.
		}
	}
```

If we are displaying results, we need to process any user input ourselves (previously child processes were doing
it for us). If AG8 is pressed, we want to clear window and status, prompt user for new first number, and finally
reset our `run_mode` to "input_first_number".

If user has pressed AG9 though, we want to finish calculator process (`kill_process(process).`)

```
	else{
		print "Invalid run_mode: "+run_mode. print 1/0.
	}
```

For safety and debugging reasons, it is very useful to always add line like that to your program. If you
mistype a run mode anywhere, this line will be ran and you will be notified that something went wrong. Otherwise
you could spend hours tracing down the bug.

```
	// save
	set process[1] to run_mode.
	set process[4] to child_process.
	set process[5] to first_number.
	set process[6] to operator.
	set process[7] to second_number.
	set process[8] to result.
}
```

Finally, after all the update code is done, we need to save our variables to process structure.

#### `program_list.ks`

Don't forget to add your widget as an entry to `program_list.ks` file. Otherwise, you won't be able to even
select your widget from the main menu.
