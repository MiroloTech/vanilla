module ui

import src.geom { Vec2 }
import src.std { Tree, Color }

@[heap]
pub struct FileTree {
	Basic
	pub mut:
	tree              Tree               = Tree{}
	
	button_height     ?&f64
	button_classes    ?&string
	
	mut:
	buttons           []&Button          = []&Button{}
	format_yid        int
}




pub fn (mut file_tree FileTree) set_tree(tree Tree) {
	file_tree.tree = tree
	
	// TODO : Add icons to button
	
	main_button := file_tree.build_buttons(tree, 0)
	file_tree.add_child(main_button)
	for mut btn in file_tree.buttons {
		btn.hide_children()
	}
}

fn (mut file_tree FileTree) build_buttons(tree Tree, depth int) Button {
	button_height :=               *(file_tree.button_height            or { file_tree.style.get[ f64    ](file_tree.classes, "FileTree:button_height") })
	button_classes :=              *(file_tree.button_classes           or { file_tree.style.get[ string ](file_tree.classes, "FileTree:button_classes") })
	default_padding_left :=                                                 *file_tree.style.get[ f64    ]([]string{}, "Button:padding_left")
	is_folder := tree.children.len > 0
	
	xoff := default_padding_left + f64(depth) * 10.0
	mut button := Button{
		style: file_tree.style
		pos: uiconst(Vec2{file_tree.pos.x, 0})
		size: uiconst(Vec2{file_tree.size.x, button_height})
		classes: button_classes.split(";")
		text: uiconst(" " + tree.name)
		padding_left: uiconst(xoff)
		name: tree.name
	}
	
	if is_folder {
		button.on_pressed.connect(fn ( btn_data voidptr ) {
			mut btn := unsafe { &Button(btn_data) }
			is_first_visible := btn.children[0].visible
			if is_first_visible {
				btn.hide_children()
			} else {
				btn.show_children()
			}
		}, mut &button)
		button.icon = "folder"
		button.icon_color = uiconst(Color.hex("#ff"))
	} else {
		button.icon = "file"
		button.icon_color = uiconst(Color.hex("#88"))
	}
	
	file_tree.buttons << &button
	
	for child in tree.children {
		child_btn := file_tree.build_buttons(child, depth + 1)
		button.add_child(child_btn)
	}
	
	return button
}

pub fn (mut file_tree FileTree) format(_ &Component) {
	file_tree.format_yid = 0
	file_tree.format_children(mut file_tree.children[0])
}

fn (mut file_tree FileTree) format_children(mut parent &Component) {
	ypos := file_tree.pos.y
	button_height :=               *(file_tree.button_height            or { file_tree.style.get[ f64    ](file_tree.classes, "FileTree:button_height") })
	
	if !parent.visible { return }
	parent.pos.y = file_tree.format_yid * button_height + ypos
	file_tree.format_yid++
	
	for mut child in parent.children {
		file_tree.format_children(mut &child)
	}
}

