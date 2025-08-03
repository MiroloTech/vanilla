module ui

import gg
import sokol.sapp

import src.geom { Vec2, Spacing }

@[heap]
pub struct Scene {
	pub mut:
	children             []Component
}


// > TODO : Implement z_index
pub fn (mut scene Scene) draw(mut ctx gg.Context) {
	// > Dependant formatting
	/*
	for mut c in scene.children {
		// TODO : Formatting
	}
	*/
	
	// > Rendering
	draw_recursively(scene.children, mut ctx)
}


pub fn draw_recursively(children []Component, mut ctx gg.Context) {
	for child in children {
		if child.children.len > 0 {
			draw_recursively(child.children, mut ctx)
		}
		child.draw(mut ctx)
	}
}

pub fn (mut scene Scene) event(mut ctx gg.Context, event &gg.Event) {
	sapp.set_mouse_cursor(.default)
	
	for mut c in scene.children {
		c.event(mut ctx, event)
	}
}


pub interface Component {
	draw(mut gg.Context)
	
	mut:
	event(mut gg.Context, &gg.Event)
	
	classes              []string
	style                &Style
	pos                  &Vec2
	size                 &Vec2
	children             []Component
}

pub struct Basic {
	pub mut:
	classes              []string
	style                &Style
	pos                  &Vec2
	size                 &Vec2
	children             []Component
}
pub fn (mut basic Basic) event(mut _ gg.Context, _ &gg.Event) {  }


