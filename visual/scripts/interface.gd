extends ColorRect

@onready var left : Button = get_node("LeftArrow/LeftButton")
@onready var right : Button = get_node("RightArrow/RightButton")
@onready var limg : TextureRect = get_node("LeftArrow")
@onready var rimg : TextureRect = get_node("RightArrow")

@onready var s1 : Control = get_node("Screen1")
@onready var s2 : Control = get_node("Screen2")

@export var page : int = 0
@export var num_pages : int = 2

func _ready() -> void:
	right.pressed.connect(forward)
	left.pressed.connect(backward)
	toggle_visible()


func forward() -> void:
	if page < num_pages-1:
		page += 1
	toggle_visible()


func backward() -> void:
	if page > 0:
		page -= 1
	toggle_visible()
	

func toggle_visible() -> void:
	if page <= 0:
		left.disabled = true
		limg.visible = false
	else:
		left.disabled = false
		limg.visible = true

	if page >= num_pages-1:
		right.disabled = true
		rimg.visible = false
	else:
		right.disabled = false
		rimg.visible = true
		
	if page == 0:
		s1.visible = true
		s2.visible = false
		
	if page == 1:
		s1.visible = false
		s2.visible = true
