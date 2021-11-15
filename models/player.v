module models

import gg
import gx
import engine as eng

pub struct Player {
	eng.GameObjectEmbed
mut:
	bounding_shape eng.BoundingShape
	in_air         bool = true
	is_alive       bool = true
}

pub fn (mut p Player) die() {
	p.is_alive = false
}

pub fn new_player(impulse_tag string, impulse eng.Vec2D, shape eng.BoundingShape, object eng.GameObjectEmbed) Player {
	return Player{
		id: object.id
		gg: object.gg
		forces: {
			impulse_tag: impulse
		}
		position: object.position
		size: object.size
		bounding_shape: shape
	}
}

pub fn (p Player) is_in_air() bool {
	return p.in_air
}

pub fn (mut p Player) toggle_in_air(val bool) {
	p.in_air = val
}

pub fn (p Player) draw() {
	p.gg.draw_rect(p.position.x, p.position.y, p.size.width, p.size.height, gx.black)
	p.gg.draw_empty_rect(p.bounding_shape.x, p.bounding_shape.y, p.bounding_shape.width,
		p.bounding_shape.height, if p.is_alive { gx.green } else { gx.red })
}

pub fn (mut p Player) update() {
	net_impulse := eng.GameObject(p).net_impulse()

	p.position.x += net_impulse.x
	p.position.y += net_impulse.y

	p.bounding_shape = eng.new_rect(p.bounding_shape.x + net_impulse.x, p.bounding_shape.y +
		net_impulse.y, p.bounding_shape.width, p.bounding_shape.height)
}

pub fn (p Player) is_collider() bool {
	return true
}
