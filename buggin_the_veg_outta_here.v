module main

import gg
import gx
import os
import math
import engine as eng
import models

const (
	win_width  = 600
	win_height = 300
)

enum Layer {
	player
	obstacle
	ground
	hole
	air
}

fn new_game_object(layer Layer, impulse eng.Vec2D, object eng.GameObjectEmbed) eng.GameObject {
	x := match layer {
		.player {
			models.Player{
				id: object.id
				gg: object.gg
				impulse: impulse
				position: object.position
				size: object.size
			}
		}
		else {
			models.Player{}
		}
	}

	return eng.GameObject(x)
}

struct App {
mut:
	gg       &gg.Context
	image    gg.Image
	curr_ndx int
	objects  map[int]eng.GameObject
	layers   map[Layer][]int
}

fn main() {
	mut app := &App{
		gg: 0
	}
	app.gg = gg.new_context(
		bg_color: gx.white
		width: win_width
		height: win_height
		create_window: true
		window_title: 'Rectangles'
		frame_fn: frame
		user_data: app
		init_fn: init_images
	)

	mut player := new_game_object(.player, eng.Vec2D{1, 0},
		id: 0
		size: gg.Size{
			width: 20
			height: 20
		}
		position: eng.Point2D{
			x: 30
			y: 30
		}
		gg: app.gg
	)
	app.image = app.gg.create_image(os.resource_abs_path('logo.png'))
	app.layers[.player] << player.id
	app.objects[player.id] = player
	app.gg.run()
}

fn init_images(mut app App) {
	// app.image = gg.create_image('logo.png')
}

fn frame(mut app App) {
	app.update()
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (mut app App) update() {
	for _, mut elem in app.objects {
		elem.update()
	}
}

fn (app &App) draw() {
	for _, elem in app.objects {
		elem.draw()
	}
}
