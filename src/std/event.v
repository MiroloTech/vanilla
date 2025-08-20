module std

import gg
import src.tlog

type EventFN = fn (mut origin voidptr, event Event)


pub struct Event {
	pub mut:
	name              string                                    = "unnamed"
	keybindings       []KeyBinding
	meta              map[string]string
	ref               voidptr                                   = unsafe { nil }
	description       string
	functions         []EventFN
}

pub fn Event.basic(name string, func EventFN) Event {
	return Event{
		name: name
		functions: [func]
	}
}
pub fn Event.empty(name string) Event {
	return Event{
		name: name
		functions: []EventFN{}
	}
}


pub fn (event Event) is_ready() bool {
	return event.functions.len > 0
}


pub fn (mut event Event) trigger() {
	for f in event.functions {
		f(mut event.ref, event)
	}
}

pub fn (mut event Event) trigger_with_meta(meta map[string]string) {
	event.meta = meta.clone()
	for f in event.functions {
		f(mut event.ref, event)
	}
}

pub fn (mut event Event) trigger_from(mut origin voidptr) {
	event.ref = origin
	for f in event.functions {
		f(mut origin, event)
	}
}

pub fn (mut event Event) trigger_from_with_meta(mut origin voidptr, meta map[string]string) {
	event.meta = meta.clone()
	for f in event.functions {
		f(mut event.ref, event)
	}
}

pub fn (mut events []Event) trigger(name string) {
	tlog.funfact("Event triggered : ${name}")
	for mut event in events {
		if event.name == name {
			event.trigger()
			return
		}
	}
	tlog.error("Event '${name}' not found in array of events")
}

pub fn (mut events []Event) trigger_from(name string, mut origin voidptr) {
	tlog.funfact("Event triggered : ${name}")
	for mut event in events {
		if event.name == name {
			event.trigger_from(mut origin)
			return
		}
	}
	tlog.error("Event '${name}' not found in array of events")
}

// TODO : Create trigger functions with meta data




pub struct KeyBinding {
	mut:
	bitfiled   u64
	
	pub mut:
	keys       []gg.KeyCode       = []gg.KeyCode{}
}

pub fn (mut bind KeyBinding) down(key gg.KeyCode) {
	key_idx := bind.keys.index(key)
	if key_idx == -1 { return }
	v := u64(1) << key_idx
	bind.bitfiled = bind.bitfiled | v
}

pub fn (mut bind KeyBinding) up(key gg.KeyCode) {
	key_idx := bind.keys.index(key)
	if key_idx == -1 { return }
	v := u64(1) << key_idx
	bind.bitfiled = bind.bitfiled & (~v)
}

pub fn (bind KeyBinding) is_active() bool {
	mut v := u64(0)
	for _ in 0..bind.keys.len {
		v = (v << 1) | u64(1)
	}
	return v == bind.bitfiled
}
