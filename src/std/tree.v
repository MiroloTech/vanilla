module std

@[heap]
pub struct TreeElement {
	pub mut:
	name         string
	meta         map[string]string    = map[string]string{}
	children     []&TreeElement       = []&TreeElement{}
}

pub fn (element TreeElement) str() string {
	return element.to_string_depth(0).replace_once("├", "┌")
}

fn (element TreeElement) to_string_depth(depth int) string {
	mut full := "│ ".repeat(depth - 1) + "├ " + element.name + "\n"
	for i, child in element.children {
		mut s := child.to_string_depth(depth + 1)
		if i == element.children.len - 1 {
			s = s.replace("├", "└")
		}
		full += s
	}
	return full
}
