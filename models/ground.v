module models

import gg
import gx
import engine as eng

[heap]
pub struct Ground {
	eng.GameObjectEmbed
mut:
	bounding_shape eng.BoundingShape
}

pub fn new_ground(impulse_tag string, impulse eng.Vec2D, shape eng.BoundingShape, object eng.GameObjectEmbed) Ground {
	return Ground{
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

pub fn (g Ground) draw() {
	g.gg.draw_rect(g.position.x, g.position.y, g.size.width, g.size.height, gx.black)
	g.gg.draw_empty_rect(g.bounding_shape.x, g.bounding_shape.y, g.bounding_shape.width,
		g.bounding_shape.height, gx.green)
}

pub fn (mut g Ground) update() {
	net_impulse := eng.GameObject(g).net_impulse()
	g.position.x += net_impulse.x
	g.position.y += net_impulse.y

	g.bounding_shape = eng.new_rect(g.bounding_shape.x + net_impulse.x, g.bounding_shape.y +
		net_impulse.y, g.bounding_shape.width, g.bounding_shape.height)
}

pub fn (g Ground) is_collider() bool {
	return true
}

pub fn (mut g Ground) impulse(impulse eng.Vec2D) {
	g.impulse = impulse
}
