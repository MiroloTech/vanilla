module ui

import os

import src.std { Image }
import src.tlog

const icon_path = os.join_path(@VMODROOT, "src/assets/icons")

__global (
	global_icons      map[string]Image
)


fn init() {
	entries := os.ls(icon_path) or { [] }
	for entry in entries {
		full_path := os.join_path(icon_path, entry)
		icon_name := entry.split(".")[0]
		if !os.is_dir(full_path) {
			global_icons[icon_name] = Image.create_from_file(full_path) or {
				tlog.warning("Error while loading icon 'icon_name' : ${err}")
				continue
			}
		}
	}
}


pub fn get_global_icon(tag string) !Image {
	return global_icons[tag] or {
		// tlog.warning("Can't find icon '${tag}' in global map of icons")
		return error("Can't find icon '${tag}' in global map of icons")
	}
}
