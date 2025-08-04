module ui

pub enum ColorSpace {
	black_white,         // Black or White : 1 bit per pixel
	l8,                  // Luminance : 8 bpp
	la8,                 // Luminance and Alpha : 16 bpp
	rg,
	rgb,
	rgba,
	cmyk,
}

pub struct Image {
	buffer          voidptr         = unsafe { nil }
}


pub fn Image.create_from_file(path string) !Image {
	
}

pub fn Image.create_from_buffer(ptr voidptr) !Image {
	mut img := Image{
		
	}
	return img
}

pub fn Image.create_empty(width int, height int, color_space ColorSpace) Image {
	mut img := Image{
		buffer
	}
	return img
}
