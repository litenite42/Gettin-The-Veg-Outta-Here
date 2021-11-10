module models

import gg
import gx
import os
import math
import engine as eng

pub struct Player {
	eng.GameObjectEmbed
}

pub fn (p Player) draw() {
	p.gg.draw_rect(p.position.x, p.position.y, p.size.width, p.size.height, gx.black)
}

pub fn (mut p Player) update() {
	angle := math.atan2(p.impulse.y, p.impulse.x)

	p.position.x += f32(math.cos(angle))
	p.position.y += f32(math.sin(angle))
}

pub fn (p Player) bounds() eng.BoundingShape {
	return gg.Rect{
		x: p.position.x
		y: p.position.y
		width: p.size.width
		height: p.size.height
	}
}
