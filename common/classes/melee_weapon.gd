extends Weapon
class_name MeleeWeapon

@export var swing_cooldown : float #time between swings
@export var swing_attack_speed : float # times you swing per second
@export var swing_distance : float #how far out each swing goes
@export var swing_arc : float #arc of each swing

@export var collision_scene : PackedScene
