module main

import gg
import gx
import os
import math

const (
	win_width  = 600
	win_height = 300
)

struct Point2D {
pub mut:
	x f32
	y f32
}

struct Vec2D {
    pub:
    x f32
    y f32
}

type BoundingShape = gg.Rect
struct GameObjectEmbed {
	id int
	mut:
	gg &gg.Context
	impulse Vec2D
	position Point2D
	size gg.Size
}

interface GameObject {
	id int
	draw()
	bounds() BoundingShape
	mut:
	gg &gg.Context
	impulse Vec2D
	position Point2D
	size gg.Size
	update() 
}

pub fn (g GameObject) str() string {
	return 'GmObj #${g.id}: imp(${g.impulse.x},${g.impulse.y}) pos(${g.position.x},${g.position.y}) size(${g.size.width}, ${g.size.height})'
}

enum Layer {
    player
    obstacle
    ground
    hole
    air
}

fn new_game_object(layer Layer, impulse Vec2D, object GameObjectEmbed) GameObject {
	x := match layer {
		.player {
			Player {
				id: object.id
				gg: object.gg
				impulse: impulse
				position: object.position
				size: object.size
			}
		} else {
			Player{}
		}
	}
	
	return GameObject(x)
}

struct Player {
	GameObjectEmbed
}

pub fn (p Player) draw() {
	println(p.position)
	p.gg.draw_rect(p.position.x, p.position.y, p.size.width, p.size.height, gx.black)
}

pub fn (mut p Player) update() {
    angle := math.atan2(p.impulse.y, p.impulse.x)
    
    p.position.x += f32(math.cos(angle))
    p.position.y += f32(math.sin(angle))
}

pub fn (p Player) bounds() BoundingShape {
	return gg.Rect{
		x: p.position.x
		y: p.position.y
		width: p.size.width
		height: p.size.height
	}
}

struct App {
mut:
	gg    &gg.Context
	image gg.Image
	curr_ndx int
	objects map[int]GameObject
	layers map[Layer][]int
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
	
	mut player := new_game_object(.player, Vec2D{1,0}, id: 0, size: gg.Size{width: 20, height: 20}, position: Point2D{x: 30, y: 30}, gg: app.gg)
	app.image = app.gg.create_image(os.resource_abs_path('logo.png'))
	app.layers[.player] << player.id
	app.objects[player.id] = player
	app.gg.run()
}

fn init_images(mut app App) {
	// app.image = gg.create_image('logo.png')
}

fn frame(mut app App) {
	for id, mut elem in app.objects {
		elem.update()
	}
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (app &App) draw() {
	for id, elem in app.objects {
		elem.draw()
	}
}
