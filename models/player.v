module models

import gg
import gx
import math
import engine as eng

pub struct Player {
	eng.GameObjectEmbed
	mut:
	bounding_shape eng.BoundingShape
}

pub fn new_player(impulse eng.Vec2D, shape eng.BoundingShape, object eng.GameObjectEmbed) Player {
	return Player{
		id: object.id
				gg: object.gg
				impulse: impulse
				position: object.position
				size: object.size
				bounding_shape: shape
	}
}

pub fn (p Player) draw() {
	p.gg.draw_rect(p.position.x, p.position.y, p.size.width, p.size.height, gx.black)
}

pub fn (mut p Player) update() {
	p.position.x += p.impulse.x
	p.position.y += p.impulse.y
	
	p.bounding_shape = eng.new_rect(p.bounding_shape.x + p.impulse.x, p.bounding_shape.y + p.impulse.y, p.bounding_shape.width, p.bounding_shape.height)
}

pub fn (p Player) is_collider() bool {
	return true
}

pub fn (mut p Player) impulse(impulse eng.Vec2D) {
	p.impulse = impulse
}
