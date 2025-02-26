extends CharacterBody2D

@export var speed : int = 350
var direction : Vector2 = Vector2.ZERO
var weapon : Weapon

func _ready() -> void:
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	if GameManager.players[str(name).to_int()].color == "CYAN":
		modulate = Color.CYAN
	if GameManager.players[str(name).to_int()].color == "ORANGE":
		modulate = Color.ORANGE
	if GameManager.players[str(name).to_int()].color == "PURPLE":
		modulate = Color.PURPLE
	if GameManager.players[str(name).to_int()].color == "MINT":
		modulate = Color.MEDIUM_SPRING_GREEN

func _physics_process(_delta: float) -> void:
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		direction = Input.get_vector("left","right","up","down")
		velocity = direction * speed
		move_and_slide()
