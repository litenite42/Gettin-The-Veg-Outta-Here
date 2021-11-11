module main

import gg
import gx
import os
import math
import engine as eng
import models

const (
	win_width     = 600
	win_height    = 300
	default_force = eng.Vec2D{1, 1}
)

enum Layer {
	player
	obstacle
	ground
	hole
	air
}

fn new_game_object(layer Layer, impulse eng.Vec2D, shape eng.BoundingShape, object eng.GameObjectEmbed) eng.GameObject {
	 match layer {
		.player {
			x := models.new_player(impulse, shape, object)
			return eng.GameObject(x) 
		}
		.ground {
			x := models.Ground{
				id: object.id
				gg: object.gg
				impulse: impulse
				position: object.position
				size: object.size
				bounding_shape: shape
			}
			
			return eng.GameObject(x)
		}
		else {
			return eng.GameObject(models.Player{})
		}
	}

	// return x
}

struct App {
mut:
	gg       &gg.Context
	image    gg.Image
	curr_ndx int
	objects  map[int]eng.GameObject
	layers   map[Layer][]int
}

fn (app App) player() ?&models.Player {
	ids := app.layers[.player]
	obj := app.objects[ids[0]]

	if obj is models.Player {
		return obj
	}
	return none
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
		window_title: 'Buggin the Veg Outta Here'
		frame_fn: frame
		keydown_fn: on_keydown
		keyup_fn: on_keyup
		user_data: app
		init_fn: init_images
	)

	app.image = app.gg.create_image(os.resource_abs_path('logo.png'))
	app.init_world()
	app.gg.run()
}

fn init_images(mut app App) {
	// app.image = gg.create_image('logo.png')
}

pub fn (mut app App) init_world(){
	mut player := new_game_object(.player, eng.Vec2D{0, 1}, eng.new_rect(win_width/2, win_height - 130,20,20),
		id: app.curr_ndx++
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
	
	app.layers[.player] << player.id
	app.objects[player.id] = player

	mut ground := new_game_object(.ground, eng.Vec2D{-1,0}, eng.Rect{x: win_width / 2, y: win_height - 100, width: win_width / 2, height: 100}, id: app.curr_ndx++ size: gg.Size{ width: win_width, height: 100 } position: eng.Point2D{x: 0, y: win_height - 100} gg: app.gg)
	
	app.layers[.ground] << ground.id
	app.objects[ground.id] = ground
}

fn frame(mut app App) {
	app.update()
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (mut app App) update() {
	mut player := app.player() or {return}
	mut pbounds := eng.BoundingShape(eng.Rect{})// player.bounds()
		p := eng.ObjectCollider(player)
		pbounds = p.bounds() 
	print('p ')
	println(pbounds)
	for _, mut elem in app.objects {
		if elem.id in app.layers[.player] {
			continue
		}
		elem.update()
		x := elem
		if x is models.Ground {
		mut gbounds := eng.BoundingShape(eng.Rect{})
		g := eng.ObjectCollider(x)
			gbounds = g.bounds()
			print('g ')
			println(gbounds)
			if eng.overlap(gbounds, pbounds) {
				//panic('Collided')
				player.impulse(x: 0, y: 0)
			}
		}
	}
	player.update()
	
	 
}

fn (app &App) draw() {
	for _, elem in app.objects {
		elem.draw()
	}
}

fn on_keyup(key gg.KeyCode, mod gg.Modifier, mut app App) {
	mut player := app.player() or { return }
	match key {
		.w, .up {
			player.impulse(default_force)
		}
		else {}
	}
}

fn on_keydown(key gg.KeyCode, mod gg.Modifier, mut app App) {
	mut player := app.player() or { return }
	match key {
		.w, .up {
			player.impulse(x: 1, y: -5)
		}
		else {}
	}
}
