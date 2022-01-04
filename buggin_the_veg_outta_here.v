module main

import gg
import gx
import os
import rand
import engine as eng
import models

const (
	win_width          = 600
	win_height         = 300
	default_force      = eng.Vec2D{0, 1}
	jump_force         = eng.Vec2D{0, -35}
	player_grav_tag    = 'pgrav'
	player_jump_tag    = 'pjump'
	floor_height       = 100
	floor_level        = win_height - floor_height
	player_spawn_level = floor_level - 50
	player_height      = 30
	player_width       = 20
)

enum Layer {
	player
	obstacle
	ground
	hole
	air
}

struct App {
mut:
	gg                 &gg.Context
	image              gg.Image
	curr_ndx           int
	objects            map[int]eng.GameObject
	layers             map[Layer][]int
	state              GameState = .run
	curr_floor_offset  int
	last_layer_spawned Layer
	same_layer_spawned int
	spawn_probability  int = 10
	score              int
	frame_count        u64
}

fn (app App) player() ?&models.Player {
	ids := app.layers[.player]
	obj := app.objects[ids[0]]

	if obj is models.Player {
		return obj
	}
	return none
}

enum GameState {
	run
	pause
	game_over
	death_screen
	main_menu
	level_select
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

pub fn (mut app App) init_world() {
	mut player := models.new_player(player_grav_tag, eng.Vec2D{1, 1}, eng.new_rect(80,
		player_spawn_level, player_width, player_height),
		id: app.curr_ndx++
		size: gg.Size{
			width: player_width
			height: player_height
		}
		position: eng.Point2D{
			x: 80
			y: player_spawn_level
		}
		gg: app.gg
	)

	app.layers[.player] << player.id
	app.objects[player.id] = player

	mut ground := models.new_ground('normal', eng.Vec2D{0, 0}, eng.Rect{
		x: 0
		y: floor_level
		width: win_width
		height: floor_height
	},
		id: app.curr_ndx++
		size: gg.Size{
			width: win_width
			height: floor_height
		}
		position: eng.Point2D{
			x: 0
			y: floor_level
		}
		gg: app.gg
	)

	app.layers[.ground] << ground.id
	app.objects[ground.id] = ground

	mut hole := models.new_hole('default', eng.Vec2D{-1, 0}, eng.Rect{
		x: win_width + 25
		y: floor_level
		width: player_width - 5
		height: floor_height
	},
		id: app.curr_ndx++
		size: gg.Size{
			width: player_width + 5
			height: floor_height
		}
		position: eng.Point2D{
			x: win_width + 20
			y: floor_level
		}
		gg: app.gg
	)
	app.layers[.hole] << hole.id
	app.objects[hole.id] = hole
}

fn frame(mut app App) {
	if app.state == .run {
		app.update()
	}
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (mut app App) death_screen() {
	app.gg.draw_text_def(win_width / 2, win_height / 2, 'You are dead')
	app.state = .death_screen
}

fn (mut app App) toggle_pause() {
	app.state = if app.state == .run { GameState.pause } else { GameState.run }
}

fn (mut app App) pause() {
	app.gg.draw_text_def(win_width / 2, win_height / 2, 'Paused')
	app.state = .pause
}

fn (mut app App) update() {
	mut player := app.player() or { return }
	mut pbounds := eng.BoundingShape(eng.Rect{})
	p := eng.ObjectCollider(player)
	mut gmo := eng.GameObject(player)
	player.update()
	pbounds = p.bounds()
	if rand.u64() % 120 == 0 {
		app.spawn_object()
	}
	player.toggle_in_air(true)
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
			if eng.overlap(gbounds, pbounds) {
				facing := eng.check_collision(pbounds, gbounds, fn (s1 eng.BoundingShape, s2 eng.BoundingShape) eng.CollisionResult {
					no_collision_temp := eng.CollisionResult(false)
					if s1 is eng.Rect {
						if s2 is eng.Rect {
							x := s1.collision_side(s2)
							return eng.CollisionResult(x)
						} else {
							return no_collision_temp
						}
					} else {
						return no_collision_temp
					}
				})

				if player.is_in_air() {
					player.toggle_in_air(false)
				}
				// 				if player.position.x > elem.position.x && player.position.y >= elem.position.y {
				// 				player.set_position(x: player.position.x,y: elem.position.y - player.size.height)
				// 				}
				// 				else
				if player.position.x + player.size.width >= elem.position.x
					&& player.position.y + player.size.height > elem.position.y
					&& player.position.y < elem.position.y + elem.size.height {
					if 'spush' !in player.forces.keys() {
						gmo.impulse('spush', x: -1, y: 0)
					}
				}
			} else {
				if 'spush' in player.forces.keys() {
					gmo.rmv_impulse('spush')
				}
			}
		}
		if x is models.Hole {
			mut gbounds := eng.BoundingShape(eng.Rect{})
			g := eng.ObjectCollider(x)
			gbounds = g.bounds()
			if eng.overlap(gbounds, pbounds) {
				player.toggle_in_air(true)
				if pbounds.y > gbounds.y + 3 {
					player.die()
					app.death_screen()
				}
			}
		}
	}

	if player.is_in_air() {
		if player_grav_tag !in player.forces.keys() {
			gmo.impulse(player_grav_tag, default_force)
			gmo.rmv_impulse(player_jump_tag)
		}
	} else {
		gmo.rmv_impulse(player_grav_tag)
	}

	if app.frame_count % 20 == 0 {
		app.score++
	}

	app.frame_count++
}

fn (mut app App) draw() {
	for _, elem in app.objects {
		elem.draw()
	}
	if app.state == .death_screen {
		app.death_screen()
	} else if app.state == .pause {
		app.pause()
	}
	app.draw_score()
}

fn (app App) draw_score() {
	app.gg.draw_text_def(10, 10, 'Score: ${app.score:d}')
}

fn (mut app App) spawn_object() {
	x := rand.u64()
	mod_5 := x % 10
	mut gmo := eng.GameObject(models.Ground{})

	mut layer := if mod_5 < 3 {
		Layer.hole
	} else if mod_5 < 5 {
		Layer.ground
	} else {
		Layer.air
	}

	if layer == app.last_layer_spawned && app.same_layer_spawned == 3 {
		return
	}
	if layer == .hole {
		hole := models.new_hole('default', eng.Vec2D{-1, 0}, eng.Rect{
			x: win_width + 25
			y: floor_level
			width: player_width - 5
			height: floor_height
		},
			id: app.curr_ndx++
			size: gg.Size{
				width: player_width + 5
				height: floor_height
			}
			position: eng.Point2D{
				x: win_width + 20
				y: floor_level
			}
			gg: app.gg
		)
		gmo = eng.GameObject(hole)
	} else if layer == .ground {
		ground := models.new_ground('normal', eng.Vec2D{-1, 0}, eng.Rect{
			x: win_width + 20
			y: floor_level + .75 * jump_force.y
			width: 20
			height: 15
		},
			id: app.curr_ndx++
			size: gg.Size{
				width: 20
				height: 15
			}
			position: eng.Point2D{
				x: win_width + 20
				y: floor_level + .75 * jump_force.y
			}
			gg: app.gg
		)
		gmo = eng.GameObject(ground)
	} else {
		return
	}

	app.layers[layer] << gmo.id
	app.objects[gmo.id] = gmo
	if layer == app.last_layer_spawned {
		app.same_layer_spawned++
	} else {
		app.last_layer_spawned = layer
		app.same_layer_spawned = 1
	}
}

fn on_keyup(key gg.KeyCode, mod gg.Modifier, mut app App) {
}

fn on_keydown(key gg.KeyCode, mod gg.Modifier, mut app App) {
	mut xplayer := app.player() or { return }
	match key {
		.w, .up {
			mut player := eng.GameObject(xplayer)
			if !xplayer.is_in_air() && player_jump_tag !in player.forces.keys() {
				player.impulse(player_jump_tag, jump_force)
				player.rmv_impulse(player_grav_tag)

				xplayer.toggle_in_air(true)
			}
		}
		.p, .enter {
			app.toggle_pause()
		}
		else {}
	}
}
