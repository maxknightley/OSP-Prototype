extends Node2D

# Velocity of character, used to handle movement across the stage.
var velocity = Vector2.ZERO
# Whether the character can move based on player input. Set this to FALSE when cutscenes or dialogue are active.
var canMove = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# Reset horizontal movement.
	velocity.x = 0
	
	# Check if the character should be moving left or right.
	if Input.is_action_pressed("move_left"): velocity.x -= 2.7
	if Input.is_action_pressed("move_right"): velocity.x += 2.7
		
	# If the player is holding the "run" button, increase their velocity accordingly.
	if Input.is_action_pressed("run"): velocity.x *= 2.4
	
	# Adjust the leader's position.
	if canMove: position += velocity
