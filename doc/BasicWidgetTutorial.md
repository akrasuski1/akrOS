# Basic widget tutorial

akrOS - simple operating system made in kOS is made of modular parts called *widgets*. 
These are separate programs that run in one particular window at a time.
They are of highest interest for other developers, as they allow you to create 
specific programs suitable for specific cases - for example rover control.
As a matter of convention, all widgets are saved in separate files, called
`job_somename`, for example `job_vessel_stats`. The only other place you will
have to edit in order to make your widget available in akrOS, is `program_list.ks`.

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
