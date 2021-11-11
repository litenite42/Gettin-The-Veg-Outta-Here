module models

import gg
import gx
import math
import engine as eng

pub struct Player {
	eng.GameObjectEmbed
}

pub fn (p Player) draw() {
	p.gg.draw_rect(p.position.x, p.position.y, p.size.width, p.size.height, gx.black)
}

pub fn (mut p Player) update() {
	p.position.x += p.impulse.x
	p.position.y += p.impulse.y
}

pub fn (p Player) bounds() eng.BoundingShape {
	return eng.Rect{
		x: p.position.x
		y: p.position.y
		width: p.size.width
		height: p.size.height
	}
}

pub fn (mut p Player) impulse(impulse eng.Vec2D) {
	p.impulse = impulse
}
