module ui

import src.tlog as log
import src.std { Color }
import x.json2
import os


type JsonValue = f64 | string | int | bool | Color

@[heap]
pub struct Style {
	pub mut:
	// TODO : Load from real JSON file
	objects            map[string]map[string]JsonValue       = {}
	classes            map[string]map[string]JsonValue       = {}
	variables          map[string]JsonValue                  = {}
}

pub fn (mut style Style) clear() {
	style.objects.clear()
	style.classes.clear()
}

pub fn (mut style Style) load_from_file(path string) ! {
	raw := os.read_file(path) or { return error("Can't open style file .json in path '${path}' : ${err}") }
	decoded := json2.raw_decode(raw) or { return error("Can't parse JSON file at '${path}' for style : ${err}") }
	
	for obj, obj_data in decoded.as_map() {
		mut data := map[string]JsonValue{}
		for key, value in obj_data.as_map() {
			data_key := key
			data[data_key] = any2json_value(value) or {
				log.warning("Can't parse value '${value}' at '${data_key}' from style sheet : ${err}")
				continue
			}
		}
		if obj == "--" {
			style.variables = data.clone()
		} else if obj.starts_with(".") {
			style.classes[obj.trim_left(".")] = data.clone()
		} else {
			style.objects[obj] = data.clone()
		}
	}
	
	log.info("Stylesheet at '${path}' finished loading")
}

fn any2json_value(any json2.Any) !JsonValue {
	match any {
		string      { if any.starts_with("#") { return JsonValue(Color.hex(any)) } else { return JsonValue(any) } }
		int         { return JsonValue(any) }
		i16         { return JsonValue(int(any)) }
		i32         { return JsonValue(int(any)) }
		i64         { return JsonValue(int(any)) }
		u8          { return JsonValue(int(any)) }
		u16         { return JsonValue(int(any)) }
		u32         { return JsonValue(int(any)) }
		u64         { return JsonValue(int(any)) }
		f64         { return JsonValue(any) }
		bool        { return JsonValue(any) }
		else        { return error("Can't parse type '${typeof(any).name}' of '${any}' implemented JsonValue") }
	}
}



pub fn (style &Style) get[T](classes []string, tag string) &T {
	// > Split tag into object/class and property
	obj_key := tag.split(":")[0]
	property_key := tag.split(":")[1] or {
		log.error("Invalid style tag given '${tag}', tag mus include at least one ':', seperating the object/class from the value name")
		return unsafe { nil }
	}
	
	// > Find object in map
	obj := (style.objects[obj_key] or {
		log.error("Can't find given object ${obj_key} in style sheet")
		return unsafe { nil }
	}).clone()
	
	// > Return unusable value, if tag is not in the style page
	mut value := obj[property_key] or {
		log.error("Can't find tag '${property_key}' in object in style sheet")
		return unsafe { nil }
	}
	
	if value is string {
		if (value as string).starts_with("--") {
			value = style.get_variable(value as string)
		}
	}
	
	// > Return unusable value, if the value in the style doesn't match the expected one
	if !(value is T) {
		type_name := typeof(T{}).name
		log.error("Value '${value}' in style map doesn't match expected type : ${typeof(value).name} > ${type_name}")
		return unsafe { nil }
	}
	
	// > Find alternative value in classes
	for class in classes {
		class_obj := (style.classes[class] or {
			log.warning("Can't find style class '${class}' in style sheet, class will be ignored")
			continue
		}).clone()
		
		class_value := class_obj[property_key] or { continue }
		if class_value is string {
			if class_value.starts_with("--") {
				value = style.get_variable(class_value)
			} else {
				value = JsonValue(class_value)
			}
		} else {
			if !(class_value is T) { continue }
			value = class_value
		}
	}
	
	return &(value as T)
}


pub fn (style Style) get_variable(tag string) JsonValue {
	if !tag.starts_with("--") {
		log.warning("Invalid variable tag '${tag}' given : Variables have to start with '--'")
		return JsonValue(tag)
	}
	
	value := style.variables[tag] or {
		log.warning("Can't find varaible tag '${tag}' in stylesheet map of variables")
		return JsonValue(tag)
	}
	
	return value
}



pub fn (style Style) get_value[T](tag string) T {
	// > Set variable
	if tag.starts_with("--") {
		return (style.variables[tag] or {
			log.warning("Can't get style value : Variable tag ${tag} not found in stylesheet variables")
			return T{}
		} as T)
	}
	
	// > Split tag into object/class and property
	obj_key := tag.split(":")[0]
	property_key := tag.split(":")[1] or {
		log.warning("Invalid style tag given '${tag}', tag mus include at least one ':', seperating the object/class from the value name")
		return T{}
	}
	
	// > Get object OR class object
	obj := if obj_key.starts_with(".") {
		(style.classes[obj_key.trim_left(".")] or {
			log.warning("Can't get style value : Can't find class '${obj_key}' in stylesheet")
			return T{}
		}).clone()
	} else {
		(style.objects[obj_key.trim_left(".")] or {
			log.warning("Can't get style value : Can't find object '${obj_key}' in stylesheet")
			return T{}
		}).clone()
	}
	
	value := obj[property_key] or {
		log.warning("Can't get style value : Property '${property_key}' doesn't exist in object/class '${obj_key}")
		return T{}
	}
	
	// > Return unusable value, if the value in the style doesn't match the expected one
	if !(value is T) {
		type_name := typeof(T{}).name
		log.warning("Can't get style value : Value '${value}' in style map doesn't match expected type : ${typeof(value).name} > ${type_name}")
		return T{}
	}
	
	return value as T
}


pub fn (mut style Style) set_value[T](tag string, value T) {
	// > Set variable
	if tag.starts_with("--") {
		if !(tag in style.variables) {
			log.warning("Can't set style value : Variable tag ${tag} not found in stylesheet variables")
			return
		}
		v := unsafe { style.variables[tag] }
		if !(v is T) {
			type_name := typeof(T{}).name
			log.warning("Can't set style value : Variable value given doesn't match the expected one : ${type_name} > ${typeof(v).name}")
			return
		}
		
		style.variables[tag] = value
		return
	}
	
	// > Split tag into object/class and property
	obj_key := tag.split(":")[0]
	property_key := tag.split(":")[1] or {
		log.warning("Invalid style tag given '${tag}', tag must include at least one ':', seperating the object/class from the value name")
		return
	}
	
	
	// > Set class value
	if obj_key.starts_with(".") {
		if !(obj_key.trim_left(".") in style.classes) {
			log.warning("Can't set style value : class '${obj_key}' is not a registered class")
			return
		}
		
		if !(property_key in style.classes[obj_key.trim_left(".")]) {
			log.warning("Can't set style value : property '${property_key}' is not in style class")
			return
		}
		
		if !(style.classes[obj_key.trim_left(".")][property_key] or { T{} } is T) {
			log.warning("Can't set style value : property type doesn't match expected type")
			return
		}
		
		style.classes[obj_key.trim_left(".")][property_key] = value
	}
	// > Set object value
	else {
		if !(obj_key in style.objects) {
			log.warning("Can't set style value : obj '${obj_key}' is not a registered object")
			return
		}
		
		if !(property_key in style.objects[obj_key]) {
			log.warning("Can't set style value : property '${property_key}' is not in style object")
			return
		}
		
		if !(style.objects[obj_key][property_key] or { T{} } is T) {
			log.warning("Can't set style value : property type doesn't match expected type")
			return
		}
		
		style.objects[obj_key][property_key] = value
	}
}



// Utillity function to create a variable of desired type on stack to then reference that ( safeley collected by garbage collector )
pub fn uiconst[T](value T) &T {
	mut v := T{}
	v = value
	return &v
}
