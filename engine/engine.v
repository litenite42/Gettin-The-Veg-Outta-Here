module engine

import gg

// point in 2D space
pub struct Point2D {
pub mut:
	x f32
	y f32
}

// vector in 2D space
pub struct Vec2D {
pub mut:
	x f32
	y f32
}

// custom wrapper around gg.Rect
pub struct Rect {
	gg.Rect
}

// gets the upper left and lower right points of a rect
pub fn (r Rect) to_bounding() (Point2D, Point2D) {
	return Point2D{r.x, r.y}, Point2D{r.x + r.width, r.y + r.height}
}

// test if one rectangle overlaps another
pub fn (r Rect) overlaps(test Rect) bool {
	l1, r1 := r.to_bounding()
	l2, r2 := test.to_bounding()

	if l1.x == r1.x || l1.y == r1.y || l2.x == r2.x || l2.y == r2.y {
		return false
	}

	if l1.x <= r2.x && r1.x >= l2.x && l1.y <= r2.y && r1.y >= l2.y {
		return true
	}
	return false
}

// instantiate a new rectangle
pub fn new_rect(x f32, y f32, w f32, h f32) Rect {
	return Rect{
		x: x
		y: y
		width: w
		height: h
	}
}

pub type BoundingShape = Rect | gg.Rect

pub fn overlap(s1 BoundingShape, s2 BoundingShape) bool {
	match s1 {
		Rect {
			match s2 {
				Rect {
					return s1.overlaps(s2)
				}
				else {
					return false
				}
			}
		}
		else {
			return false
		}
	}
	return false
}

pub interface ObjectCollider {
	bounding_shape BoundingShape
	is_collider() bool
}

pub fn (o ObjectCollider) bounds() BoundingShape {
	return o.bounding_shape
}

// basic structure that all game objects will use
pub struct GameObjectEmbed {
pub:
	id int
pub mut:
	forces   map[string]Vec2D
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
	forces map[string]Vec2D
	position Point2D
	size gg.Size
	update()
}

pub fn (mut g GameObject) impulse(tag string, impulse Vec2D) {
	g.forces[tag] = impulse
}

pub fn (mut g GameObject) rmv_impulse(tag string) {
	if tag in g.forces {
		g.forces.delete(tag)
	}
}

pub fn (mut g GameObject) clear_forces() {
	for i in g.forces.keys() {
		g.forces.delete(i)
	}
}

pub fn (g GameObject) net_impulse() Vec2D {
	mut net_impulse := Vec2D{}

	for _, force in g.forces {
		net_impulse.x += force.x
		net_impulse.y += force.y
	}

	return net_impulse
}

pub fn (g GameObject) str() string {
	impulse := g.net_impulse()
	return 'GmObj #$g.id: imp($impulse.x,$impulse.y) pos($g.position.x,$g.position.y) size($g.size.width, $g.size.height)'
}

pub interface Kinematic {
	GameObject
	ObjectCollider
}
