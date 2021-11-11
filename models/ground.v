module models

import gg
import gx
import os
import math
import engine as eng

[heap]
pub struct Ground {
	eng.GameObjectEmbed
	bounding_shape eng.BoundingShape
}

pub fn (g Ground) draw() {
	g .gg.draw_rect(g .position.x, g .position.y, g .size.width, g .size.height, gx.black)
	g .gg.draw_rect(g.bounding_shape.x, g .bounding_shape.y, g .bounding_shape.width, g .bounding_shape.height, gx.white)
}

pub fn (mut g Ground) update() {
	g .position.x += g.impulse.x
	g .position.y += g.impulse.y
}

pub fn (g Ground) is_collider() bool {
	return true
}

pub fn (mut g Ground) impulse(impulse eng.Vec2D) {
	g .impulse = impulse
}
