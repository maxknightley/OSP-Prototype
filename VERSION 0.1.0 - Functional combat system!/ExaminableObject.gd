extends Area2D

signal sendTextToDisplay

# Variable to determine whether the player can "speak" to/"read"/"examine" the object.
# Turns on when the "leading character" is colliding with it, off otherwise.
var active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# If the player examines this object, we send out a signal containing two things.
	# First, an array containing every line of dialogue, along with talksprites (as appropriate).
	# Second - optionally - a function that should be called to initiate a battle, a dialogue CHOICE,
	# etc - anything that would require further scripting and affects the level.
	if Input.is_action_just_pressed("ui_accept") && active:
		emit_signal("sendTextToDisplay", 
			[["This is a sign!", "res://Assets/sign_placeholder_talksprite.png", "RF"],
			["By pressing 'Z', you've accessed some GENERIC TEST DIALOGUE.","res://Assets/sign_placeholder_talksprite.png", "RF"],
			["(You wait a moment.)", false, false],
			["That's all it says - \nbut you can read it again if you like.","res://Assets/baqi_placeholder_talksprite.png", "LF"]],
			"test battle")

func _on_Sign_body_entered(body):
	$AnimatedSprite.play("highlighted")
	active = true

func _on_Sign_body_exited(body):
	$AnimatedSprite.play("default")
	active = false
