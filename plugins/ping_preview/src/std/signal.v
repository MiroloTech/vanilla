module std

pub struct Signal {
	pub mut:
	app        voidptr                          = unsafe { nil }
	func       fn (Signal)                      = fn (_ Signal) {  }
}

pub fn (signal Signal) emit() {
	signal.func(signal)
}
