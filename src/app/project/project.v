module project

import os

import src.std { Tree }

pub struct Project {
	pub mut:
	path                  string
	hidden_file_pahts     []string
	name                  string
	run_command           string
}

pub fn (project Project) get_file_tree() Tree {
	return get_file_tree_recursive(project.path)
}


fn get_file_tree_recursive(path string) Tree {
	// TODO : Use os.ls to get all entries
	mut tree := Tree{name: os.file_name(path)}
	entries := os.ls(path) or { []string{} }
	for entry in entries {
		new_path := os.join_path(path, entry)
		if os.is_dir(new_path) {
			sub_tree := get_file_tree_recursive(new_path)
			tree.children << &sub_tree
		} else {
			tree.children << &Tree{name: os.file_name(new_path)}
		}
	}
	return tree
}
