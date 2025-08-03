module tlog

import term

pub fn info[T](txt T) {
	println(term.blue("${txt}"))
}

pub fn funfact[T](txt T) {
	println(term.gray("${txt}"))
}

pub fn warning[T](txt T) {
	println(term.yellow("${txt}"))
}

pub fn error[T](txt T) {
	println(term.red("${txt}"))
}

pub fn header[T](txt T) {
	println(term.bold("${txt}"))
}

pub fn debug[T](txt T) {
	println(term.gray(">> ${txt}"))
}
