extends Spatial

var peer_id

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_server(9999)
	if error:
		peer.create_client('127.0.0.1', 9999)
	else:
		get_tree().connect("network_peer_connected", self, "_player_connected")
		get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		get_tree().connect("connected_to_server", self, "_connected_ok")
		get_tree().connect("connection_failed", self, "_connected_fail")
		get_tree().connect("server_disconnected", self, "_server_disconnected")

	get_tree().network_peer = peer
	
	peer_id = get_tree().get_network_unique_id()
	
	var p = preload("res://Player.tscn").instance()
	p.set_name(str(peer_id))
	p.set_network_master(1)
	add_child(p)
	p.global_transform.origin = $Position3D.global_transform.origin

func _player_connected(id):
	print("peer connected")
	rpc_id(id, 'add_server_player')
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc("register_player", id)
	for p in get_tree().get_network_connected_peers():
		if id == p:
			continue
		rpc_id(id, "register_player", p)
#	rpc_id(id, "register_player", id)

func _player_disconnected(id):
	pass

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.
	
remote func add_server_player():
	var p = preload("res://NetworkPlayer.tscn").instance()
	p.set_name(str(1))
	p.set_network_master(1)
	add_child(p)

remotesync func register_player(id):
	print(id)
	if id == peer_id:
		return
	# Get the id of the RPC sender.
	# Store the info
	var p = preload("res://NetworkPlayer.tscn").instance()
	p.set_name(str(id))
	p.set_network_master(1)
	add_child(p)
	p.global_transform.origin = $Position3D.global_transform.origin
