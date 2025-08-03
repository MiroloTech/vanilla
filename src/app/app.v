module app

import gg
import os

import src.tlog as log
import src.geom { Vec2, Spacing }
import src.std { Color, Signal, Event }
import src.ui { Scene, Button, Panel, Style, uiconst }


// @[heap]
pub struct App {
	pub mut:
	ctx                  &gg.Context           = unsafe { nil }
	style                Style                 = Style{}
	scene                Scene                 = Scene{}
	
	plugin_loaders       []PluginLoader        = []PluginLoader{}
	events               map[string]Event
	
	other_color          Color                 = Color.hex("#ffffff")
	pings                int
	screen_size          Vec2                  = Vec2{600.0, 400.0}
}


fn (mut app App) init() {
	// Init UI
	app.style.load_from_file(@VMODROOT + "/style_default.json") or {
		log.error("Can't load style file : ${err}")
		panic("")
	}
	
	app.scene.children << Panel{
		pos: uiconst(Vec2{0.0, 0.0})
		size: &app.screen_size
		style: &app.style
		radius: uiconst(0.0)
	}
	
	app.scene.children << Panel{
		pos: uiconst(Vec2{50.0, 200.0})
		size: uiconst(Vec2{100.0, 100.0})
		style: &app.style
		// color: &app.other_color
		classes: ["panel-main"]
	}
	app.scene.children << Panel{
		pos: uiconst(Vec2{200.0, 200.0})
		size: uiconst(Vec2{100.0, 100.0})
		style: &app.style
		classes: ["panel-main"]
	}
	
	app.scene.children << Panel{
		pos: uiconst(Vec2{50.0, 50.0})
		size: uiconst(Vec2{100.0, 100.0})
		style: &app.style
		classes: ["panel-special"]
	}
	
	app.scene.children << Panel{
		pos: uiconst(Vec2{50.0, 200.0})
		size: uiconst(Vec2{100.0, 100.0})
		style: &app.style
		// color: &app.other_color
		classes: ["panel-main"]
	}
	
	app.scene.children << Button{
		pos: uiconst(Vec2{200.0, 350.0})
		size: uiconst(Vec2{150.0, 25.0})
		style: &app.style
		text: uiconst("Add ping")
		on_pressed: Signal{app: app, func: fn ( signal Signal ) {
			mut app := unsafe { &App(signal.app) }
			app.pings += 1
			println("Ping count : ${app.pings}")
	
			unsafe { app.events["ping"].trigger_from(mut app) }
		}}
	}
	
	// Init plugins
	log.info("Loading plugins...")
	app.load_plugins()
	log.info("Plugin loading finished")
	
	
	app.plugin_loaders.trigger_init(mut app)
	
	
	// Init Events
	unsafe { app.events["ping"] = Event.basic("ping", app.plugin_loaders.trigger_event) }
}


fn (mut app App) frame() {
    app.ctx.begin()
    app.scene.draw(mut app.ctx)
    app.ctx.end()
	
	window_size := app.ctx.window_size()
	app.screen_size = Vec2{ f64(window_size.width), f64(window_size.height) }
	
	app.other_color.a -= 0.01
	if app.other_color.a <= 0.0 {
		app.other_color.a = 1.0
	}
	
	app.plugin_loaders.trigger_update(mut app)
}

fn (mut app App) event(event &gg.Event, _ voidptr) {
	app.scene.event(mut app.ctx, event)
}

fn (mut app App) cleanup() {
	for mut plugin_loader in app.plugin_loaders {
		plugin_loader.cleanup()
	}
}



fn (mut app App) load_plugins() {
	// TODO : Do this with a loop through every .dll file in lib folder
	plugin_dir := os.join_path(@VMODROOT, "plugins") // TODO : Change VMODROOT To custom folder in AppData
	plugin_loader := PluginLoader.load(plugin_dir, "ping_preview") or {
		log.error("Error while loading plugin : ${err}")
		return
	}
	app.plugin_loaders << plugin_loader
}
