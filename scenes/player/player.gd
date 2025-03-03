extends CharacterBody2D
class_name Player

enum Class {
	KING,
	WIZARD,
	WARRIOR,
	NINJA,
	SOLDIER
}
var char_class : Class

@export var boxes : int = 0
@export var health : int = 100
@export var speed : int = 350
var direction : Vector2 = Vector2.ZERO

@export var starting_weapon : Weapon

var current_progression : WeaponProgression
@export var king_progression : WeaponProgression
@export var wizard_progression : WeaponProgression
@export var warrior_progression : WeaponProgression
@export var ninja_progression : WeaponProgression
@export var soldier_progression : WeaponProgression

func _enter_tree() -> void:
	##set authority to name of player node(name should be that player's id)
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	##set colors of each player locally
	$Sprite2D.frame = GameManager.players[str(name).to_int()].frame
	char_class = GameManager.players[str(name).to_int()].frame
	
	##set the starting weapon
	$WeaponNode._change_weapon(starting_weapon)
	
	##Set weapon progression
	match char_class:
		Class.KING:
			current_progression = king_progression
		Class.WIZARD:
			current_progression = wizard_progression
		Class.WARRIOR:
			current_progression = warrior_progression
		Class.NINJA:
			current_progression = ninja_progression
		Class.SOLDIER:
			current_progression = soldier_progression
		
func _process(_delta: float) -> void:
	##IF THE USER HAS AUTHORITY OVER THE PLAYER, CONTROL IT
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		
		##MOVEMENT
		direction = Input.get_vector("left","right","up","down")
		velocity = direction * speed
		move_and_slide()
		look_at(get_global_mouse_position())
		
		if position.x > DisplayServer.window_get_size().x:
			position.x = DisplayServer.window_get_size().x
		
		if position.y > DisplayServer.window_get_size().y:
			position.y = DisplayServer.window_get_size().y
		
		if position.x < 0:
			position.x = 0
		
		if position.y < 0:
			position.y = 0
		 
		##ATTACKING
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			$WeaponNode._fire()
		
		##HEALTH
		if health <= 0:
			get_parent()._check_restart(name)
			_player_died.rpc(str(name))
			
		$Label.text = "HP: " + str(health) #Health text label
		
func _damage(damage : int) -> void:
	health -= damage
	
@rpc("any_peer","call_local")
func _add_money(money) -> void:
	boxes += money
	print("player " + name + " recieved a box! Total: " + str(boxes))
	_check_levelup()

@rpc("any_peer", "call_local")
func _player_died(name : String) -> void:
	print(name + " has died")
	queue_free()
	
func _check_levelup() -> void:
	if boxes >= 5:
		$WeaponNode._change_weapon(current_progression.weapon[0])
		print(name + " leveled up!")
	if boxes >= 15:
		$WeaponNode._change_weapon(current_progression.weapon[1])
		print(name + " leveled up!")
	if boxes >= 30:
		$WeaponNode._change_weapon(current_progression.weapon[2])
		print(name + " leveled up!")
	if boxes >= 50:
		$WeaponNode._change_weapon(current_progression.weapon[3])
		print(name + " leveled up!")
	if boxes >= 75:
		$WeaponNode._change_weapon(current_progression.weapon[4])
		print(name + " leveled up!")
