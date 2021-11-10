module engine

import gg

pub struct Point2D {
pub mut:
	x f32
	y f32
}

pub struct Vec2D {
pub:
	x f32
	y f32
}

type BoundingShape = gg.Rect

pub struct GameObjectEmbed {
pub:
	id int
pub mut:
	gg       &gg.Context
	impulse  Vec2D
	position Point2D
	size     gg.Size
}

pub interface GameObject {
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
	return 'GmObj #$g.id: imp($g.impulse.x,$g.impulse.y) pos($g.position.x,$g.position.y) size($g.size.width, $g.size.height)'
}
