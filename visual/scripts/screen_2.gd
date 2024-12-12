extends Control

signal query
signal rated

@onready var text_display : Label = get_node("BoundingBox/TextDisplay")
@onready var time_display : Label = get_node("BoundingBox/TimeDisplay")
@onready var answer_display : Label = get_node("AnswerDisplay")
@onready var text_edit : TextEdit = get_node("BoundingBox/TextEdit")
@onready var choice_edit : LineEdit = get_node("BoundingBox/ChoiceEdit")
@onready var submit_button : Button = get_node("BoundingBox/Button")
@onready var choice_button : Button = get_node("BoundingBox/ChoiceEdit/SubmitChoice")
@onready var clear_button : TextureButton = get_node("BoundingBox/ClearButton")
@onready var rate_up : TextureButton = get_node("BoundingBox/RatingUp")
@onready var rate_down : TextureButton = get_node("BoundingBox/RatingDown")

@export var max_choices : int = 4
var choices : Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rate_up.pressed.connect(rating_up)
	rate_down.pressed.connect(rating_down)
	submit_button.pressed.connect(send_query)
	choice_button.pressed.connect(add_choice)
	clear_button.pressed.connect(clear_choices)
	toggle_rating(false)

func display_response(response : String, time : int) -> void:
	toggle_rating(false)
	answer_display.text = "Answer:\n%s" % response
	time_display.text = "%s ms" % time
	
func send_query() -> void:
	if not choices.is_empty():
		query.emit(text_edit.text, choices)

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

# S2 Specific Functions
func add_choice() -> void:
	if choices.size() >= max_choices:
		return
	var text = choice_edit.text
	choice_edit.text = ""
	choices.append(text)
	update_choices()

func update_choices() -> void:
	var text : String = ""
	for choice in choices:
		text = text + choice + "\n"
	text_display.text = text

func clear_choices() -> void:
	choices.clear()
	update_choices()
