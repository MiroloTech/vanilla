module ui

import gg
import gx
import sokol.sapp

import src.geom { Vec2 }
import src.std { Color, Signal, Image, draw_icon }


@[heap]
pub struct Button {
	Basic
	pub mut:
	color_normal            ?&Color
	color_hover             ?&Color
	color_pressed           ?&Color
	text_color_normal       ?&Color
	text_color_hover        ?&Color
	text_color_pressed      ?&Color
	icon_color              ?&Color
	radius                  ?&f64
	text_size               ?&int
	text                    ?&string
	text_align              ?TextAlign
	// icon                    ?&Image
	icon                    string
	
	on_pressed              Signal             = Signal{}
	on_hovered              Signal             = Signal{}
	on_unhovered            Signal             = Signal{}
	
	toggle_mode             ?&bool
	
	padding_left            ?&f64
	padding_right           ?&f64
	
	mut:
	is_pressed              bool
	is_hovered              bool
}


pub fn (button Button) draw(mut ctx gg.Context, _ RenderInfo) {
	radius :=               *(button.radius                   or { button.style.get[ f64       ](button.classes, "Button:radius") })
	color_normal :=         *(button.color_normal             or { button.style.get[ Color     ](button.classes, "Button:color_normal") })
	color_hover :=          *(button.color_hover              or { button.style.get[ Color     ](button.classes, "Button:color_hover") })
	color_pressed :=        *(button.color_pressed            or { button.style.get[ Color     ](button.classes, "Button:color_pressed") })
	text_color_normal :=    *(button.text_color_normal        or { button.style.get[ Color     ](button.classes, "Button:text_color_normal") })
	text_color_hover :=     *(button.text_color_hover         or { button.style.get[ Color     ](button.classes, "Button:text_color_hover") })
	text_color_pressed :=   *(button.text_color_pressed       or { button.style.get[ Color     ](button.classes, "Button:text_color_pressed") })
	icon_color :=           *(button.icon_color               or { button.style.get[ Color     ](button.classes, "Button:icon_color") })
	text_size :=            *(button.text_size                or { button.style.get[ int       ](button.classes, "Button:text_size") })
	text_align :=           button.text_align                 or { TextAlign.from(*button.style.get[string](button.classes, "Button:text_align")) or { TextAlign.start } }
	text :=                 *(button.text                     or { button.style.get[ string    ](button.classes, "Button:text") })
	
	padding_left :=         *(button.padding_left             or { button.style.get[ f64       ](button.classes, "Button:padding_left") })
	padding_right :=        *(button.padding_right            or { button.style.get[ f64       ](button.classes, "Button:padding_right") })
	
	color := if button.is_pressed { color_pressed } else { if button.is_hovered { color_hover } else { color_normal } }
	text_color := if button.is_pressed { text_color_pressed } else { if button.is_hovered { text_color_hover } else { text_color_normal } }
	
	ctx.draw_rounded_rect_filled(
		f32((*button.pos).x), f32((*button.pos).y),
		f32((*button.size).x), f32((*button.size).y),
		f32(radius),
		color.get_gx()
	)
	
	pos := Vec2{
		(*button.pos).x + (*button.size).x / 2.0,
		(*button.pos).y + (*button.size).y / 2.0
	}
	
	mut x := match text_align {
		.start { (*button.pos).x + padding_left }
		.centre { pos.x }
		.end { (*button.pos).x + (*button.size).x - padding_right }
	}
	alignment := match text_align {
		.start { gx.HorizontalAlign.left }
		.centre { gx.HorizontalAlign.center }
		.end { gx.HorizontalAlign.right }
	}
	
	if icon_image := get_global_icon(button.icon) {
		w := icon_image.aspect_ratio() * ((*button.size).y - 2.0)
		draw_icon(
			mut ctx,
			icon_image,
			int(x), int((*button.pos).y + 1),
			int(w), int(((*button.size).y - 2.0)),
			icon_color
		)
		x += w + 2.0
	}
	
	ctx.draw_text(
		int(x), int(pos.y),
		text,
		color: text_color.get_gx()
		align: alignment
		vertical_align: .middle
		size: text_size
		// family: "Source Code Pro"
	)
}

pub fn (mut button Button) event(mut _ gg.Context, event &gg.Event) {
	if event.typ == .mouse_move {
		mpos := Vec2{f64(event.mouse_x), f64(event.mouse_y)}
		hovering := button.pos.x <= mpos.x && mpos.x < (button.pos.x + button.size.x) && button.pos.y <= mpos.y && mpos.y < (button.pos.y + button.size.y)
		if hovering && !button.is_hovered {
			button.on_hovered.emit()
		} else if !hovering && button.is_hovered {
			button.on_unhovered.emit()
			button.is_pressed = false
		}
		button.is_hovered = hovering
	}
	
	else if event.typ == .mouse_down {
		if button.is_hovered {
			button.on_pressed.emit()
			button.is_pressed = true
		}
	} else if event.typ == .mouse_up {
		button.is_pressed = false
	}
	
	if button.is_hovered {
		sapp.set_mouse_cursor(.pointing_hand)
	}
}


