extends Node

@onready var server : Server = get_node("Server")

func _ready() -> void:
	server.error.connect(fail)
	server.disconnected.connect(fail)
	await server.connected

	# Wait for a response
	server.recieved.connect(recv_json)

# Stop the engine if an error is encountered
func fail() -> void:
	print("Stopped execution")
	get_tree().paused = true


# Send JSON from a dictionary
func send_json(data : Dictionary) -> bool:
	return server.send(JSON.stringify(data).to_utf8_buffer())

# Recieve JSON to a dictionary
func recv_json(data : PackedByteArray) -> Dictionary:
	var string : String = data.get_string_from_utf8()
	if string.is_empty():
		printerr("Failed to decode UTF-8 from recieved array")
		fail()
		return {}

	var json : Variant = JSON.parse_string(string)
	if json.is_null():
		printerr("Failed to parse JSON from string")
		fail()
		return {}

	if not json is Dictionary:
		printerr("JSON dictionary type error")
		fail()
		return {}
	
	return json
	