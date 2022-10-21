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
	if Input.is_action_pressed("ui_accept") && active:
		emit_signal("sendTextToDisplay", 
			["This is a sign!",
			"By pressing 'Z', you've accessed some GENERIC TEST DIALOGUE.",
			"This is the last line - \nbut you can read it again if you like."])

func _on_Sign_body_entered(body):
	$AnimatedSprite.play("highlighted")
	active = true

func _on_Sign_body_exited(body):
	$AnimatedSprite.play("default")
	active = false
