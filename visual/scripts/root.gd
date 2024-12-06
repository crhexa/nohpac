extends Node

@export var HOST : String = "localhost"
@export var PORT : int = 9999
@onready var server : Server = get_node("Server")

signal responded
signal finished

var response : Dictionary = {}
var switch : bool = true

func _ready() -> void:
	server.error.connect(fail)
	server.disconnected.connect(fail)
	server.connect_to_host(HOST, PORT)

func _process(_delta : float) -> void:
	if switch:
		switch = false
		await server.connected
		print("Successfully connected")
		server.recieved.connect(recv_json)
		var reply : Dictionary = await send_reply({
			"opcode": 0,
			"prompt": "Respond with \"YES\"",
			"choices": ["YES", "NO"]
		})
		print(reply)
		send_json({"opcode": 1234})


# Stop the engine if an error is encountered
func fail() -> void:
	responded.emit()
	print("Stopped execution")
	get_tree().paused = true


# Send JSON from a dictionary
func send_json(data : Dictionary) -> bool:
	return server.send(JSON.stringify(data).to_utf8_buffer())


# Recieve JSON to a dictionary
func recv_json(data : PackedByteArray) -> void:
	var string : String = data.get_string_from_utf8()
	if string.is_empty():
		printerr("Failed to decode UTF-8 from recieved array")
		fail()
		return

	var json : Variant = JSON.parse_string(string)
	if json == null:
		printerr("Failed to parse JSON from string")
		fail()
		return

	if not json is Dictionary:
		printerr("JSON dictionary type error")
		fail()
		return
	
	response = json
	finished.emit()

# Send a query and wait for a reply
func send_reply(data : Dictionary) -> Dictionary:
	if not send_json(data):
		fail()
		return {}

	await finished
	return response
