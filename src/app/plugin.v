module app

import os
import dl
import dl.loader

import src.tlog as log
import src.std { Event }

type AppGetterFn = fn () &Plugin
type ReadyFN = fn (mut data voidptr)
type UpdateFN = fn (mut data voidptr)
type EventFN = fn (mut data voidptr, event Event)

pub struct PluginLoader {
	pub mut:
	path              string
	dl_loader         &loader.DynamicLibLoader        = unsafe { nil }
	plugin            &Plugin
	name              string
	
	mut:
	fn_ready          voidptr                         = unsafe { nil }
	fn_update         voidptr                         = unsafe { nil }
	fn_event          voidptr                         = unsafe { nil }
}

pub fn PluginLoader.load(path string, plugin_name string) !PluginLoader {
	library_file_path := os.join_path(path, dl.get_libname(plugin_name))
	if !os.is_file(library_file_path) {
		return error("Invalid file path given : ${library_file_path}")
	}
	
	mut dl_loader := loader.get_or_create_dynamic_lib_loader(
		key: plugin_name
		paths: [library_file_path]
	) or { return error("Can't create dl loader for plugins : ${err}") }
	
	sym_app_getter := dl_loader.get_sym('get_plugin') or { return error("Can't fetch 'get_plugin' symbol in plugin '${plugin_name}' : ${err}") }
	sym_ready      := dl_loader.get_sym('ready') or { return error("Can't fetch 'ready' symbol in plugin '${plugin_name}' : ${err}") }
	sym_update     := dl_loader.get_sym('update') or { return error("Can't fetch 'update' symbol in plugin '${plugin_name}' : ${err}") }
	sym_event      := dl_loader.get_sym('event') or { return error("Can't fetch 'event' symbol in plugin '${plugin_name}' : ${err}") }
	
	app_getter     := AppGetterFn(sym_app_getter)
	
	
	mut plugin := app_getter()
	
	log.info("> Plugin '${plugin_name}' succesfully loaded")
	
	return PluginLoader{
		path: library_file_path
		dl_loader: dl_loader
		plugin: plugin
		name: plugin_name
		
		fn_ready: sym_ready
		fn_update: sym_update
		fn_event: sym_event
	}
}

pub fn (mut plugin_loader PluginLoader) cleanup() {
	plugin_loader.dl_loader.unregister()
	log.info("Plugin '${plugin_loader.name}' unloaded")
}


pub interface Plugin {
	title            string
	description      string
	authors          []string
	icon             string                       // URL or Path
}


pub fn (mut plugins []PluginLoader) trigger_init(mut _ App) {
	for mut pl in plugins {
		f := ReadyFN(pl.fn_ready)
		f(mut pl.plugin)
	}
}

pub fn (mut plugins []PluginLoader) trigger_update(mut _ App) {
	for mut pl in plugins {
		f := UpdateFN(pl.fn_update)
		f(mut pl.plugin)
	}
}

pub fn (mut plugins []PluginLoader) trigger_event(mut _ App, event Event) {
	for mut pl in plugins {
		f := EventFN(pl.fn_event)
		f(mut pl.plugin, event)
	}
}

