extends Control

signal query
signal rated

@onready var text_display : Label = get_node("BoundingBox/TextDisplay")
@onready var time_display : Label = get_node("BoundingBox/TimeDisplay")
@onready var text_edit : TextEdit = get_node("BoundingBox/TextEdit")
@onready var submit_button : Button = get_node("BoundingBox/Button")
@onready var rate_up : TextureButton = get_node("BoundingBox/RatingUp")
@onready var rate_down : TextureButton = get_node("BoundingBox/RatingDown")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rate_up.pressed.connect(rating_up)
	rate_down.pressed.connect(rating_down)
	submit_button.pressed.connect(send_query)
	toggle_rating(false)

func display_response(response : String, time : int) -> void:
	toggle_rating(false)
	text_display.text = response
	time_display.text = "%s ms" % time
	
func send_query() -> void:
	query.emit(text_edit.text)

func toggle_rating(disabled : bool) -> void:
	rate_up.disabled = disabled
	rate_down.disabled = disabled

	if not disabled:
		rate_up.visible = true
		rate_up.visible = true

func rating_up() -> void:
	toggle_rating(true)
	rate_down.visible = false
	rated.emit(1)

func rating_down() -> void:
	toggle_rating(true)
	rate_up.visible = false
	rated.emit(0)
