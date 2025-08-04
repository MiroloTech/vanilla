module ui

import gg
import sokol.sapp
import time

import src.geom { Vec2, Spacing }

@[heap]
pub struct Scene {
	pub mut:
	children             []Component
	delta                f64                  = 0.0
	stopwatch            time.StopWatch       = time.StopWatch{} // time.new_stopwatch{auto_start: true}
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
	render_info := RenderInfo{
		delta: scene.stopwatch.elapsed().seconds()
	}
	draw_recursively(scene.children, mut ctx, render_info)
	
	// > Reset Drawing settings
	scene.stopwatch.restart()
}


pub fn draw_recursively(children []Component, mut ctx gg.Context, render_info RenderInfo) {
	for child in children {
		if child.children.len > 0 {
			draw_recursively(child.children, mut ctx, render_info)
		}
		child.draw(mut ctx, render_info)
	}
}

pub fn (mut scene Scene) event(mut ctx gg.Context, event &gg.Event) {
	sapp.set_mouse_cursor(.default)
	
	for mut c in scene.children {
		c.event(mut ctx, event)
	}
}


pub interface Component {
	draw(mut gg.Context, RenderInfo)
	
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


