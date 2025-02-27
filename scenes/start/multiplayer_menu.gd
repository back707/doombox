extends Control

#region Stupid references
##this is all stuipd
@onready var color_rect: ColorRect = $ColorRect
@onready var cyan: TextureButton = $VBoxContainer/HBoxContainer/Cyan
@onready var orange: TextureButton = $VBoxContainer/HBoxContainer/Orange
@onready var purple: TextureButton = $VBoxContainer/HBoxContainer/Purple
@onready var mint: TextureButton = $VBoxContainer/HBoxContainer/Mint
#endregion

@export var address : String = ""
@export var port : int = 8910

var peer : ENetMultiplayerPeer

var player_frame : int = 0

func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	multiplayer.server_disconnected.connect(server_disconnected)
	if "--server" in OS.get_cmdline_args():
		_host_game()
	
func peer_connected(id : int) -> void:
	print("Player connected:" + str(id))

func peer_disconnected(id : int) -> void:
	print("Player disconnected:" + str(id))
	GameManager.players.erase(id)
	var players = get_tree().get_nodes_in_group("Player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

func connected_to_server() -> void:
	print("Connected to Server")
	$VBoxContainer/Join.disabled = true
	_send_player_information.rpc_id(1, player_frame, multiplayer.get_unique_id())

func connection_failed() -> void:
	print("Failed to connect")

func server_disconnected() -> void:
	print("Disconnected from server")
	
@rpc("any_peer")
func _send_player_information(color_frame : int, id : int) -> void:
	if !GameManager.players.has(id):
		GameManager.players[id] = {
			"frame" : color_frame,
			"id" : id,
			"weapon" : Weapon,
			"boxes" : 0
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			_send_player_information.rpc(GameManager.players[i].frame, i)

@rpc("any_peer","call_local")
func _start_game() -> void:
	var scene : Node = load("res://scenes/main/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	print("Game started with " + str(GameManager.players.size()) + " players")
	self.hide()

func _host_game() -> void:
	peer = ENetMultiplayerPeer.new()
	var error : int = peer.create_server(port)
	if error != OK:
		print("cannot host: " + str(error))
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("waiting for players")
	
func _on_host_pressed() -> void:
	_host_game()
	_send_player_information(player_frame, multiplayer.get_unique_id())

func _on_join_pressed() -> void:
	address = $LineEdit.text
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
func _on_start_pressed() -> void:
	_start_game.rpc()


#region Color Select
func _on_cyan_pressed() -> void:
	player_frame = 1
	color_rect.position = cyan.global_position

func _on_orange_pressed() -> void:
	player_frame = 2
	color_rect.position = orange.global_position

func _on_purple_pressed() -> void:
	player_frame = 3
	color_rect.position = purple.global_position

func _on_mint_pressed() -> void:
	player_frame = 4
	color_rect.position = mint.global_position
#endregion
