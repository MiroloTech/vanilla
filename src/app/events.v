module app

import src.std { Event }

__global (
	global_events       []Event
)

fn init() {
	global_events = [
		// Debug
		Event.empty("ping"),
		
		// Log
		Event.empty("log_funfact"),
		Event.empty("log_info"),
		Event.empty("log_warning"),
		Event.empty("log_error"),
		
		// File Tree
		Event.empty("file_tree_folder_collapsed"),
		Event.empty("file_tree_folder_uncollapsed"),
		Event.empty("file_tree_file_selected"),
	]
}

