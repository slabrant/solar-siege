extends Node

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"

func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 2)
	if error != OK:
		print("Failed to create server: ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("Server started on port ", PORT)

func join_game(address = DEFAULT_SERVER_IP):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error != OK:
		print("Failed to join server: ", error)
		return
	multiplayer.multiplayer_peer = peer
	print("Joining server at ", address)
