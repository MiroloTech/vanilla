module std

import gg

type EventFN = fn (mut origin voidptr, event Event)


pub struct Event {
	pub mut:
	name              string                                    = "unnamed"
	keybindings       []KeyBinding
	meta              map[string]string
	ref               voidptr                                   = unsafe { nil }
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

pub fn (mut event Event) trigger() {
	// event.meta = meta.clone()
	// event.ref = unsafe { nil }
	for f in event.functions {
		f(mut event.ref, event)
	}
}

pub fn (mut event Event) trigger_from(mut origin voidptr) {
	// event.meta = meta.clone()
	event.ref = origin
	for f in event.functions {
		f(mut origin, event)
	}
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
