extends CharacterBody2D
class_name Enemy

@export var enemy : EnemyType
@export var current_health : int
@export var box_scene : PackedScene

var direction : Vector2

signal died

func _ready() -> void:
	current_health = enemy.health
	$Sprite2D.texture = enemy.texture
	$AnimationPlayer.play("attacking")
	$MultiplayerSynchronizer.set_multiplayer_authority(1)
	
func _process(delta: float) -> void:
	##chase the nearest player
	if get_nearest_player():
		look_at(get_nearest_player().position)
		velocity = Vector2.from_angle(rotation) * enemy.speed
		move_and_slide()
	
	##Health
	if multiplayer.get_unique_id() == 1:
		if current_health <= 0:
			_kill_enemy.rpc()
	
func get_nearest_player() -> Player:
	var players : Array = get_tree().get_nodes_in_group("Player")
	var curr_player : Node2D
	if players.front():
		var shortest_distance : float = global_position.distance_to(players[0].global_position)
		curr_player = players[0]
		for i in players:
			var curr_dist : float = global_position.distance_to(i.global_position)
			if curr_dist < shortest_distance:
				curr_player = i
				shortest_distance = curr_dist
		return curr_player
	return

func _damage(damage : int, user : Node) -> void:
	_set_enemy_health_authority.rpc(str(user.name).to_int())
	current_health -= damage
	modulate.a = float(current_health) / float(enemy.health)

func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		body._damage(enemy.damage)

@rpc("any_peer","call_local")
func _kill_enemy() -> void:
	_spawn_box()
	queue_free()

func _spawn_box() -> void:
	var box = box_scene.instantiate()
	get_parent().add_child(box)
	box.position = position
	
@rpc("any_peer","call_local")
func _set_enemy_health_authority(id : int) -> void:
	$healthSync.set_multiplayer_authority(id)
