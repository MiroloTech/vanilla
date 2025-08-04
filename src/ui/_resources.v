module ui


__global (
	images       map[string]
)

pub fn load_image_safe(path string) ! {
	
}

pub fn load_image(path string) {
	load_image_safe(path) or {
		log.error("Can't load / cache image at path '${path}' : ${err}")
		return
	}
}

pub struct Image {
	
}
