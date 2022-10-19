extends Polygon2D

# Point to the parent node, i.e. the Battlefield.
onready var parent = get_parent()

# Current X and Y position on the grid
var xPos = 0
var yPos = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Is the player attempting to move the cursor?
	var target_xPos = xPos
	var target_yPos = yPos
	
	if Input.is_action_pressed("move_right"):
		target_xPos += 1
	if Input.is_action_pressed("move_left"):
		target_xPos -= 1
	if Input.is_action_pressed("move_down"):
		target_yPos += 1
	if Input.is_action_pressed("move_up"):
		target_yPos -= 1
		
	# If the player's not attempting to move, we can ignore the rest of the function
	if target_xPos == xPos && target_yPos == yPos:
		return
	
	# IF that's a valid cell to move to, adjust cursor's drawn position
	if parent.get_cell(target_xPos, target_yPos) != -1:
		print("Valid!")
		# position = 
