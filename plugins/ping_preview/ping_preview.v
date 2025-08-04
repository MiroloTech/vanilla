import src.std { Event }
import src.tlog as log

// Compile command : v -d no_backtrace -o ping_preview -shared plugins/ping_preview

pub struct Plugin {
	pub:
	title            string               = "Ping Preview"
	description      string               = "Adds a rectangle for each newly received ping"
	authors          []string             = ["Mirolo"]
	icon             string
	
	pub mut:
	pings            int
}


@[export: "get_plugin"]
pub fn get_plugin() &Plugin {
	return &Plugin{}
}

@[export: "ready"]
pub fn ready(mut plugin_ptr voidptr) {
	plugin := unsafe { &Plugin(plugin_ptr) }
	// log.funfact("Plugin ${plugin.title} loaded")
}

@[export: "update"]
pub fn update(mut _ voidptr) {
	
}

@[export: "event"]
pub fn event(mut plugin_ptr voidptr, event Event) {
	mut plugin := unsafe { &Plugin(plugin_ptr) }
	plugin.pings += 1
	log.debug("Event received '${event.name}' with meta : ${event.meta}")
	log.debug("${plugin.pings} pings")
}

