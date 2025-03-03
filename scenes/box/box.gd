extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if multiplayer.get_unique_id() == 1:
			body._add_money.rpc(1)
			_destroy.rpc()

@rpc("any_peer","call_local")
func _destroy() -> void:
	queue_free()
