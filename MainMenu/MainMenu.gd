extends Control

@onready var play_button = $VBoxContainer/Play
@onready var options_button = $VBoxContainer/Options
@onready var exit_button = $VBoxContainer/Exit

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_play_pressed():
	print("MainMenu: Play pressed. Loading Playground scene...")
	var scene = load("res://Scenes/main_scene.tscn") as PackedScene
	if scene:
		get_tree().change_scene_to_packed(scene)
		print("MainMenu: Scene change requested")
	else:
		print("MainMenu: Failed to load scene")

func _on_options_pressed():
	print("MainMenu: Options pressed")

func _on_exit_pressed():
	get_tree().quit()
