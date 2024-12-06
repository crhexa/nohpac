class_name Server extends Node
# Code adapted from https://www.bytesnsprites.com/posts/2021/creating-a-tcp-client-in-godot/

signal connected
signal recieved
signal disconnected
signal error

var _status: int = 0
var _stream: StreamPeerTCP = StreamPeerTCP.new()

func update() -> void:
	_stream.poll()
	_status = _stream.get_status()

func _ready() -> void:
	update()

func _process(_delta: float) -> void:
	update()
	if _status == _stream.STATUS_NONE:
		print("Disconnected from host.")
		disconnected.emit()

	elif _status == _stream.STATUS_ERROR:
		print("Error with socket stream.")
		error.emit()

	elif _status == _stream.STATUS_CONNECTED:
		connected.emit()
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			var data: Array = _stream.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				print("Error getting data from stream: ", data[0])
				error.emit()
			else:
				recieved.emit(PackedByteArray(data[1]))

func connect_to_host(host: String, port: int) -> void:
	print("Attempting to connect to %s:%d" % [host, port])

	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	if _stream.connect_to_host(host, port) != OK:
		print("Error connecting to host.")
		error.emit()
		return

	while _stream.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		_stream.poll()

	if _status == _stream.STATUS_ERROR:
		print("Error establishing connection, problem with socket stream.")
		error.emit()

func send(data: PackedByteArray) -> bool:
	if _status != _stream.STATUS_CONNECTED:
		print("Error: Stream is not currently connected.")
		return false

	var err: int = _stream.put_data(data)
	if err != OK:
		print("Error writing to stream: ", err)
		return false

	return true
