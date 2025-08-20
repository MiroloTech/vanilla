module std

@[heap]
pub struct Tree {
	pub mut:
	name         string
	meta         map[string]string    = map[string]string{}
	children     []&Tree              = []&Tree{}
}

pub fn (element Tree) str() string {
	return element.to_string_depth(0).replace_once("├", "┌")
}
pub fn (tree []Tree) str() string {
	mut result := ""
	for entry in tree {
		result += "${entry.name}\n"
	}
	return result
}


fn (element Tree) to_string_depth(depth int) string {
	mut full := "│ ".repeat(depth - 1) + "├ " + element.name + "\n"
	for child in element.children {
		mut s := child.to_string_depth(depth + 1)
		/*
		if i == element.children.len - 1 {
			s = s.replace("├", "└")
		}
		*/
		full += s
	}
	return full
}

// get_all_children returns all children of the tree, found and sorted using depth-first search. Element 0 is the given root tree
pub fn (tree Tree) get_all_children() []Tree {
	mut tree_list := [tree]
	for children in tree.children {
		tree_list << (*children).get_all_children()
	}
	return tree_list
}



pub fn (tree Tree) get_tree_data(depth int) []TreeData {
	mut data := [TreeData{depth: depth, tree: tree}]
	for element in tree.children {
		data << element.get_tree_data(depth + 1)
	}
	return data
}

pub struct TreeData {
	pub:
	depth             int
	tree              Tree
}

pub fn (data TreeData) str() string {
	return "${data.depth} : ${data.tree.name}"
}
