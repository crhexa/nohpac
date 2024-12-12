extends Node

@export var HOST : String = "localhost"
@export var PORT : int = 9999
@onready var server : Server = get_node("Server")
@onready var gui : Control = get_node("Interface")
@onready var s1 : Control = get_node("Interface/Screen1")
@onready var s2 : Control = get_node("Interface/Screen2")
@onready var exit_button : Button = get_node("Interface/ExitIcon/ExitButton")

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
		s1.query.connect(open_ended)
		s2.query.connect(multiple_choice)
		exit_button.pressed.connect(exit)

func multiple_choice(question : String, choices : Array[String]) -> void:
	var elapsed : int = Time.get_ticks_msec()
	var reply : Dictionary = await send_reply({
		"opcode": 0,
		"prompt": question,
		"choices": choices
	})
	elapsed = Time.get_ticks_msec() - elapsed
	s2.display_response(reply["response"], elapsed)
	print("[DEBUG] Query took %s ms" % elapsed)
	
func open_ended(question : String) -> void:
	var elapsed : int = Time.get_ticks_msec()
	var reply : Dictionary = await send_reply({
		"opcode": 1,
		"prompt": question,
	})
	elapsed = Time.get_ticks_msec() - elapsed
	s1.display_response(reply["response"], elapsed)
	print("[DEBUG] Query took %s ms" % elapsed)

		
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
