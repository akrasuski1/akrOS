parameter process.
global __akros_update_result__ is 0.
if process<>0{
local update_index is get_process_update_function_index(process).
if false {}
else if update_index=0{global __akros_update_result__ is update_vessel_stats(process).}
else if update_index=1{global __akros_update_result__ is update_window_manager(process).}
else if update_index=2{global __akros_update_result__ is update_process_manager(process).}
else if update_index=3{global __akros_update_result__ is update_menu(process).}
else if update_index=4{global __akros_update_result__ is update_main_menu(process).}
else{print __akros_invalid_update_function_index__error_message__. print 1/0.}
}
