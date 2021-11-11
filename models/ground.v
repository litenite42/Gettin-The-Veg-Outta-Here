module models

import gg
import gx
import os
import math
import engine as eng

[heap]
pub struct Ground {
	eng.GameObjectEmbed
}

pub fn (g Ground) draw() {
	g .gg.draw_rect(g .position.x, g .position.y, g .size.width, g .size.height, gx.black)
}

pub fn (mut g Ground) update() {
	g .position.x += g.impulse.x
	g .position.y += g.impulse.y
}

pub fn (g Ground) bounds() eng.BoundingShape {
	return eng.Rect{
		x: g .position.x
		y: g .position.y
		width: g .size.width
		height: g .size.height
	}
}

pub fn (mut g Ground) impulse(impulse eng.Vec2D) {
	g .impulse = impulse
}
