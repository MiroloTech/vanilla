module main

import gg

import src.std { Color }
import src.app { App }

fn main() {
	mut app_struct := &App{}
    app_struct.ctx = gg.new_context(
        bg_color:     Color.hex("#232323").get_gx()
        width:        600
        height:       400
		user_data:    app_struct
        window_title: 'Vanilla UI'
        frame_fn:     app_struct.frame
		event_fn:     app_struct.event
        init_fn:      app_struct.init
		cleanup_fn:   app_struct.cleanup
    )
	app_struct.ctx.run()
}

