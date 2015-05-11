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

// add to OS
parameter os_data.
register_program(os_data,"Calculator","run_calculator",false).
```

It is very similar to what you saw in basic widget tutorial. Note that we will need number dialog, which is not
included with standard akrOS package, so we need to include it here via `run job_number_dialog.` Although
we also use menu widget, we don't need to include it explicitly, because it *is* a part of standard akrOS package,
since it is used by the main menu. Feel free to include it if you want, though.

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


