extends CharacterBody2D
class_name Bullet

var shooter : WeaponNode
var speed : int

var direction : Vector2
var collision : KinematicCollision2D


func _process(delta: float) -> void:
	collision = move_and_collide(direction * speed * delta)
	
	if multiplayer.get_unique_id() == str(shooter.get_parent().name).to_int():
		if collision:
			if collision.get_collider() is Enemy:
				shooter._on_weapon_hit(collision.get_collider())
			
