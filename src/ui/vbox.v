module ui


@[heap]
pub struct VBox {
	Basic
	pub mut:
	spacing          ?&f64
}

pub fn (mut vbox VBox) format(_ &Component) {
	spacing := *(vbox.spacing or { vbox.style.get[f64](vbox.classes, "VBox:spacing") })
	
	mut y := vbox.pos.y
	for mut child in vbox.get_children() {
		child.pos.y = y
		
		child.pos.x = vbox.pos.x
		child.size.x = vbox.size.x
		
		y += child.size.y + spacing
	}
}
