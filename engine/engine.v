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

pub type Rect = gg.Rect

pub fn (r Rect) to_bounding() (Point2D, Point2D) {
	return Point2D{r.x, r.y}, Point2D{r.x+r.width,r.y+r.height}
}

pub fn (r Rect) overlaps(test Rect) bool {
	l1,r1 := r.to_bounding()
	l2,r2 := test.to_bounding()
	
	if l1.x == r1.x || l1.y == r1.y || l2.x == r2.x || l2.y == r2.y {
						return false
						}
					
					 if l1.x >= r2.x || l2.x >= r1.x {
						return false
						}
					if r1.y >= l2.y || l1.y >= r2.y {
						return false
						}
						return true
}

pub type BoundingShape = gg.Rect | Rect

pub fn overlap(s1 BoundingShape, s2 BoundingShape) bool {
	match s1 {
		Rect {
			match s2 {
				Rect {
					return s1.overlaps(s2)
				} else {
					return false
				}
			}
		} else {
			return false
		}
	}
	return false
}

pub interface ObjectCollider {
	bounds() BoundingShape
}

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

pub interface Kinematic {
	GameObject
	ObjectCollider
}
