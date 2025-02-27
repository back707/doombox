extends CharacterBody2D
class_name Enemy

@export var enemy : EnemyType

var health : int
var direction : Vector2

func _ready() -> void:
	health = enemy.health
	$Sprite2D.texture = enemy.texture
	$AnimationPlayer.play("attacking")
	
func _process(delta: float) -> void:
	##chase the nearest player
	look_at(get_nearest_player().position)
	velocity = Vector2.from_angle(rotation) * enemy.speed
	move_and_slide()
	
	##Health
	if multiplayer.get_unique_id() == 1:
		if health <= 0:
			_kill_enemy.rpc()
	
func get_nearest_player() -> Player:
	var players : Array = get_tree().get_nodes_in_group("Player")
	var curr_player : Node2D
	var shortest_distance : float = global_position.distance_to(players[0].global_position)
	curr_player = players[0]
	for i in players:
		var curr_dist : float = global_position.distance_to(i.global_position)
		if curr_dist < shortest_distance:
			curr_player = i
			shortest_distance = curr_dist
	return curr_player

func _damage(damage : int) -> void:
	health -= damage

func _on_attack_zone_body_entered(body: Node2D) -> void:
	if body is Player:
		body._damage(enemy.damage)

@rpc("any_peer","call_local")
func _kill_enemy() -> void:
	queue_free()
