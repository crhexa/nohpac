extends Node

@export var HOST : String = "localhost"
@export var PORT : int = 9999
@onready var server : Server = get_node("Server")
@onready var gui : Control = get_node("Interface")

signal responded
signal finished

var response : Dictionary = {}
var connected : bool = false

func _ready() -> void:
	server.error.connect(fail)
	server.disconnected.connect(fail)
	server.connect_to_host(HOST, PORT)

func _process(_delta : float) -> void:
	if not connected:
		connected = true
		await server.connected
		print("Successfully connected")
		server.recieved.connect(recv_json)
		var reply : Dictionary = await send_reply({
			"opcode": 0,
			"prompt": "Respond with \"YES\"",
			"choices": ["YES", "NO"]
		})
		print(reply)

func multiple_choice(question : String, choices : Array[String]) -> int:
	var elapsed : int = Time.get_ticks_msec()
	await send_reply({
		"opcode": 0,
		"prompt": question,
		"choices": choices
	})
	#getreply and update gui
	return Time.get_ticks_msec() - elapsed
	
func open_ended(question : String, context : String) -> int:
	var elapsed : int = Time.get_ticks_msec()
	await send_reply({
		"opcode": 1,
		"prompt": question,
	})
	#getreply and update gui
	return Time.get_ticks_msec() - elapsed
		
func exit() -> void:
	close_server()
	get_tree().quit()

#region Server Functions
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
	
func close_server() -> void:
	send_json({"opcode": 1234})
#endregion
