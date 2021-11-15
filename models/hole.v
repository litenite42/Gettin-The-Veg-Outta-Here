module models

import gg
import gx
import engine as eng

[heap]
pub struct Hole {
	eng.GameObjectEmbed
mut:
	bounding_shape eng.BoundingShape
}

pub fn new_hole(impulse_tag string, impulse eng.Vec2D, shape eng.BoundingShape, object eng.GameObjectEmbed) Hole {
	return Hole{
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

pub fn (h Hole) draw() {
	h.gg.draw_rect(h.position.x, h.position.y, h.size.width, h.size.height, gx.white)
	h.gg.draw_empty_rect(h.bounding_shape.x, h.bounding_shape.y, h.bounding_shape.width,
		h.bounding_shape.height, gx.green)
}

pub fn (mut h Hole) update() {
	net_impulse := eng.GameObject(h).net_impulse()
	h.position.x += net_impulse.x
	h.position.y += net_impulse.y

	h.bounding_shape = eng.new_rect(h.bounding_shape.x + net_impulse.x, h.bounding_shape.y +
		net_impulse.y, h.bounding_shape.width, h.bounding_shape.height)
}

pub fn (h Hole) is_collider() bool {
	return true
}

pub fn (mut h Hole) impulse(impulse eng.Vec2D) {
	h.impulse = impulse
}
