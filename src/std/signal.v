module std

import src.tlog

type FnConnection  = fn (app voidptr)

pub struct Signal {
	mut:
	// from       voidptr                          = unsafe { nil }
	apps       []voidptr                        = []
	funcs      []FnConnection                   = []
}

pub fn (mut signal Signal) connect(func FnConnection, mut app voidptr) {
	signal.funcs << func
	signal.apps << app
}

pub fn (signal Signal) emit() {
	for i, func in signal.funcs {
		mut app := signal.apps[i] or {
			tlog.error("Error in Signal, number of apps '${signal.apps.len}' and functions '${signal.funcs.len}' doesn't match up, rendering the Signal defective and useless")
			return
		}
		func(app)
	}
}
