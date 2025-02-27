extends Weapon
class_name RangedWeapon

@export var bullet_speed : int #speed of bullet
@export var fire_cooldown : float #time in s between shots
@export var pierce : int # number of objects its bullets can pierce (0 will hit 1 enemy)

@export var bullet_texture : Texture2D 
