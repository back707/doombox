extends Node2D
class_name WeaponNode

#this is the currently used weapon
@export var weapon : Weapon

##weapon local variables
var sprite : Sprite2D 
var cooldown : float
var is_cooling : bool = false

##melee local variables
var starting_rotation : float
var swing_time : float
var is_swinging : bool = false
var colide : Area2D 

func _ready() -> void:
	if weapon is MeleeWeapon: #reset melee weapon cooldowns
		cooldown = weapon.swing_cooldown
		
	if weapon is RangedWeapon: #reset range weapon cooldowns
		cooldown = 1 / weapon.fire_attack_speed
	
func _process(delta: float) -> void:
	if is_swinging: #swing!
		_swing(delta)
	if is_cooling: #cooldown!
		_cooldown(delta)
	
func _on_weapon_hit(body : Node2D) -> void:
		if body is Enemy:
			body._damage(weapon.damage, get_parent())

func _change_weapon(new_weapon : Weapon) -> void: #this can be called to swap to a new weapon
	weapon = new_weapon
	
	##Change Weapon  sprite
	if sprite:
		remove_child(sprite)
	sprite = weapon.sprite.instantiate()
	add_child(sprite)
	
	##change weapon collision if melee
	if weapon is MeleeWeapon:
		remove_child(colide)
		colide = weapon.collision_scene.instantiate()
		add_child(colide)
		colide.body_entered.connect(_on_weapon_hit)
		colide.monitoring = false

func _fire() -> void: # call this when firing off current weapon regardless of type
	if weapon is MeleeWeapon:
		if !is_swinging && !is_cooling:
			rotation_degrees = 0 + (weapon.swing_arc/2)
			starting_rotation = rotation_degrees
			swing_time = 1 / weapon.swing_attack_speed
			is_swinging = true
			
	if weapon is RangedWeapon:
		if multiplayer.get_unique_id() == str(get_parent().name).to_int():
			_spawn_bullet.rpc()

func _cooldown(delta) -> void: # this is for the weapon cooldown
	if weapon is MeleeWeapon:
		colide.monitoring = false
		cooldown -= delta
		if cooldown <= 0:
			is_cooling = false
			cooldown = weapon.swing_cooldown
			
	if weapon is RangedWeapon:
		cooldown -= delta
		if cooldown <= 0:
			is_cooling = false
			cooldown = 1 / weapon.fire_attack_speed

func _swing(delta) -> void: #this is for the animation for melee weapons
	if weapon is MeleeWeapon:
		colide.monitoring = true
		swing_time -= delta
		rotation_degrees = starting_rotation - ((swing_time / (1 / weapon.swing_attack_speed)) * weapon.swing_arc)
		position.x = weapon.swing_distance * abs(2 *(abs((swing_time / (1 / weapon.swing_attack_speed)) - 0.5) - 0.5))
		if swing_time <= 0:
			is_swinging = false
			is_cooling = true
			position = Vector2(0,0)
			rotation_degrees = 0
			
@rpc("any_peer","call_local")
func _spawn_bullet() -> void:
	if weapon is RangedWeapon:
			if !is_cooling:
				var new_bullet : Bullet = weapon.bullet_body.instantiate()
				get_parent().get_parent().add_child(new_bullet, true)
				new_bullet.position = global_position
				new_bullet.shooter = self
				new_bullet.speed = weapon.bullet_speed
				new_bullet.direction = Vector2.from_angle(get_parent().rotation)
				new_bullet.rotation = get_parent().rotation
				is_cooling = true
