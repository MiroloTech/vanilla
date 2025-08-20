module ui

import src.tlog as log

__global (
	images = map[string]string{}
)

pub fn load_image_safe(path string) ! {
	return
}

pub fn load_image(path string) {
	load_image_safe(path) or {
		log.error("Can't load / cache image at path '${path}' : ${err}")
		return
	}
}
