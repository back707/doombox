extends Node2D
@export var player_scene : PackedScene
@export var enemy_scene : PackedScene
@export var wave_amount : int = 1
@export var wave_amount_interval_period : int = 3
var wave_amount_interval : int
@export var spawn_timer : float = 5
var spawn_timer_length : float

signal restart

func _ready() -> void:
	##Spawner Priority
	$MultiplayerSpawner.set_multiplayer_authority(1)
	
	##spawn in players to corresonding spawn points
	var index = 0 
	for i in GameManager.players:
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.players[i].id)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				current_player.global_position = spawn.global_position
		index += 1
		
	##spawner movement
	spawn_timer_length = spawn_timer
	$EnemySpawner/AnimationPlayer.play("circling")
	
func _process(delta: float) -> void:
	_spawn_timer(delta)
	

func _spawn_timer(delta) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0:
		spawn_timer = spawn_timer_length
		_spawn_wave(wave_amount)
		wave_amount_interval += 1
		if wave_amount_interval >= wave_amount_interval_period:
			wave_amount += 1
			wave_amount_interval = 0
			
func _spawn_wave(amount) -> void:
	if multiplayer.get_unique_id() == 1:
		print("spawned a wave of " + str(amount))
		while amount > 0:
			var instance = enemy_scene.instantiate()
			add_child(instance, true)
			instance.position = $EnemySpawner.position + Vector2(randf_range(-100,100),randf_range(-100,100))
			amount -= 1
			
func _check_restart(player) -> void:
	for child in get_children():
		if child is Player and !child.name == player:
			return
	print("restart")
	_restart.rpc()
	restart.emit()
	
@rpc("any_peer","call_local")
func _restart() -> void:
	queue_free()
