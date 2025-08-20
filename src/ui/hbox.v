module ui


@[heap]
pub struct Hbox {
	Basic
	pub mut:
	spacing          ?&f64
}

pub fn (mut hbox Hbox) format(_ &Component) {
	spacing := *(hbox.spacing or { hbox.style.get[f64](hbox.classes, "VBox:spacing") })
	
	mut x := hbox.pos.x
	for mut child in hbox.get_children() {
		if child.visible == false { continue }
		
		child.pos.x = x
		
		child.pos.y = hbox.pos.y
		child.size.y = hbox.size.y
		
		x += child.size.x + spacing
	}
}
