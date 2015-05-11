# Common widgets

The purpose of this file is to describe the basic utility widgets bundled with akrOS. Currently, there are only
two of them: menu and number dialog, but in case this number increases, this is the place their documentation can
be placed.

## Menu

![Screenshot](http://i.imgur.com/wleJumv.png)
* description: This widget shows a simple menu, allowing user to make a choice from a certain list. The used action
groups are:
  - AG7 - move current selection up
  - AG8 - move current selection down
  - AG9 - accept current selection
* file: `job_menu.ks`
* run_function: `run_menu`
* arguments:
  - os_data
  - window_index
  - title (string to be printed over the choices)
  - list_of_names (list of choices to be printed)
  - return_index (boolean which if true, causes the function to return index of choice instead)
* return value: if return_index is false (recommended), returns the chosen value. Otherwise (return_index is true),
returns the index of the chosen value.
