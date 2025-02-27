extends CharacterBody2D

@export var speed : int = 350
var direction : Vector2 = Vector2.ZERO

@export var starting_weapon : Weapon


func _ready() -> void:
	##set authority to name of player node(name should be that player's id)
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	
	##set colors of each player locally
	if GameManager.players[str(name).to_int()].color == "CYAN":
		modulate = Color.CYAN
	if GameManager.players[str(name).to_int()].color == "ORANGE":
		modulate = Color.ORANGE
	if GameManager.players[str(name).to_int()].color == "PURPLE":
		modulate = Color.PURPLE
	if GameManager.players[str(name).to_int()].color == "MINT":
		modulate = Color.MEDIUM_SPRING_GREEN
		
	##Set all players' weapon to the selected starting weapon locally
	for i in GameManager.players:
		GameManager.players[i].weapon = starting_weapon
		$WeaponNode._change_weapon(starting_weapon)

	
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
