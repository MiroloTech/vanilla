module ui

import gg
import sokol.sapp
import time

import src.geom { Vec2, Spacing }
import src.std { Color }

const debug_color := Color.hex("#ff00ff")

@[heap]
pub struct Scene {
	pub mut:
	children             []Component
	delta                f64                  = 0.0
	stopwatch            time.StopWatch       = time.StopWatch{} // time.new_stopwatch{auto_start: true}
}

pub fn (scene Scene) get_children() []Component {
	mut children := []Component{}
	for child in scene.children {
		if child.visible {
			children << child
		}
	}
	return children
}


// > TODO : Implement z_index
pub fn (mut scene Scene) draw(mut ctx gg.Context) {
	// > Update parent references for each component
	update_parent(mut scene.children)
	
	// > Dependant formatting
	for mut c in scene.get_children() {
		c.format(unsafe { nil })
	}
	
	// > Rendering
	render_info := RenderInfo{
		delta: scene.stopwatch.elapsed().seconds()
	}
	draw_recursively(scene.get_children(), mut ctx, render_info)
	
	// > Reset Drawing settings
	scene.stopwatch.restart()
}


pub fn (scene Scene) draw_debug(mut ctx gg.Context) {
	draw_debug_recursively(scene.get_children(), mut ctx)
}


pub fn update_parent(mut children []Component) {
	for mut child in children {
		if child.children.len > 0 {
			for mut sub_child in child.children {
				// println("Parent set: ${child.name} for ${sub_child.name}")
				sub_child.parent = unsafe { &child }
				// println(sub_child.parent.name)
			}
			update_parent(mut child.children)
		}
	}
}


pub fn draw_recursively(children []Component, mut ctx gg.Context, render_info RenderInfo) {
	for child in children {
		if child.children.len > 0 {
			draw_recursively(child.get_children(), mut ctx, render_info)
		}
		child.draw(mut ctx, render_info)
	}
}

pub fn draw_debug_recursively(children []Component, mut ctx gg.Context) {
	for child in children {
		if child.children.len > 0 {
			draw_debug_recursively(child.get_children(), mut ctx)
		}
		child.draw_debug(mut ctx)
	}
}


pub fn (mut scene Scene) event(mut ctx gg.Context, event &gg.Event) {
	sapp.set_mouse_cursor(.default)
	
	mut to_trigger := []Component{}
	for c in scene.children {
		to_trigger << c
	}
	
	for to_trigger.len > 0 {
		len := to_trigger.len
		for cid in 0..len {
			mut c := to_trigger[cid]
			c.event(mut ctx, event)
			to_trigger << c.children
		}
		to_trigger.delete_many(0, len)
	}
}

@[heap]
pub interface Component {
	draw(mut gg.Context, RenderInfo)
	draw_debug(mut gg.Context)
	
	get_children() []Component
	is_visible() bool
	get_child(int) &Component
	
	mut:
	event(mut gg.Context, &gg.Event)
	format(&Component)
	
	hide()
	show()
	hide_children()
	show_children()
	
	classes              []string
	style                &Style
	name                 string
	pos                  &Vec2
	size                 &Vec2
	children             []Component
	parent               &Component
	visible              bool
}

@[heap]
pub struct Basic {
	pub mut:
	classes              []string
	style                &Style
	name                 string                  = "unnamed"
	pos                  &Vec2
	size                 &Vec2
	children             []Component
	parent               &Component              = unsafe { nil }
	visible              bool                    = true
}

pub fn (basic Basic) draw_debug(mut ctx gg.Context) {
	ctx.draw_rect_empty(
		f32(basic.pos.x), f32(basic.pos.y),
		f32(basic.size.x), f32(basic.size.y),
		debug_color.get_gx()
	)
	
	ctx.draw_text(
		int(basic.pos.x + 6.0),
		int(basic.pos.y + 6.0),
		basic.name,
		color: debug_color.get_gx()
	)
}

pub fn (basic Basic) draw(mut _ gg.Context, _ RenderInfo) {  }

pub fn (mut basic Basic) event(mut _ gg.Context, _ &gg.Event) {  }

pub fn (mut basic Basic) format(_ &Component) {
	for mut child in basic.children {
		child.pos = basic.pos
		child.size = basic.size
	}
}


// === Generic UI Component functions ===

pub fn (basic Basic) get_children() []Component {
	mut children := []Component{}
	for child in basic.children {
		if child.visible {
			children << child
		}
	}
	return children
}

pub fn (mut basic Basic) hide() {
	basic.visible = false
}
pub fn (mut basic Basic) show() {
	basic.visible = true
}
pub fn (mut basic Basic) hide_children() {
	for mut child in basic.children {
		child.visible = false
	}
}
pub fn (mut basic Basic) show_children() {
	for mut child in basic.children {
		child.visible = true
	}
}

pub fn (basic Basic) is_visible() bool {
	// mut current := Component(basic)
	/*
	for true {
		// print("${current.parent} - ")
		if !current.visible { return false }
		if current.parent == unsafe { nil } {
			break
		}
		current = *(current.parent)
	}
	// print("\n")
	*/
	return basic.visible
}

pub fn (mut basic Basic) add_child(child Component) {
	basic.children << child
}

pub fn (basic Basic) get_child(idx int) &Component {
	return &(basic.children[idx] or { return unsafe { nil } })
}


