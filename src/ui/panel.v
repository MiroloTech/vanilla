module ui

import gg

import src.std { Color }


@[heap]
pub struct Panel {
	Basic
	pub mut:
	color       ?&Color
	radius      ?&f64
}



pub fn (panel Panel) draw(mut ctx gg.Context) {
	radius := *(panel.radius or { panel.style.get[f64](panel.classes, "Panel:radius") })
	color := *(panel.color or { panel.style.get[Color](panel.classes, "Panel:color") })
	
	ctx.draw_rounded_rect_filled(
		f32((*panel.pos).x), f32((*panel.pos).y),
		f32((*panel.size).x), f32((*panel.size).y),
		f32(radius),
		color.get_gx()
	)
}

