extends Node2D

# Point to the parent node, i.e. the Battlefield.
onready var parent = get_parent()

# Create an empty Velocity vector, which defaults to zero. ADD COMMENT IF THIS WORKS
var velocity = Vector2.ZERO
# ADD COMMENT IF THIS WORKS
var newPosition = Vector2.ZERO

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(320, 352)
	newPosition = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Scale the player. Default scale, at the back, is 0.75 times the normal values.
	# We want the maximum scale value to be 1.1, or +0.35 from the default
	# Since there are 6 x 64 tiles, that's a total distance of 384, and thus...
	var scaleFactor = 0.75 + (0.35 * (position.y - 320) / 384)
	scale.x = scaleFactor
	scale.y = scaleFactor
	
	# If player presses "confirm," update position to match the cursor's position
	if Input.is_action_pressed("ui_accept"):
		# First, determine the target yPosition, and assign newPosition.y accordingly.
		# We add 32 so that the character will be aligned to the *middle* of the cell.
		newPosition.y = parent.map_to_world(parent.cursorPosition).y + 32
		
		# X-position is trickier, due to the distortion.
		# I tried a bunch of Math Ways to figure this out, but it never quite worked...
		# ...So we're going to just assign it based on the individual cell.
		
		### NOTE: All of these THEORETICALLY use consistent formulae, but I couldn't get that working.
		### If we can streamline this to an cell-x-index check and the formulae themselves, we should!
		### ...But we can figure that out later.
		match parent.cursorPosition:
			Vector2(0, 0): newPosition.x = 320 # 320 - y * 17.2
			Vector2(1, 0): newPosition.x = 384 # 384 - y * 11.2
			Vector2(2, 0): newPosition.x = 454 # 454 - y * 5.2
			Vector2(3, 0): newPosition.x = 520 # 520 + 2y
			Vector2(4, 0): newPosition.x = 588 # 588 + y * 8.2
			Vector2(5, 0): newPosition.x = 654 # 654 + y * 14.4
			
			Vector2(0, 1): newPosition.x = 302.8
			Vector2(1, 1): newPosition.x = 372.8
			Vector2(2, 1): newPosition.x = 448.8
			Vector2(3, 1): newPosition.x = 522
			Vector2(4, 1): newPosition.x = 596.2
			Vector2(5, 1): newPosition.x = 668.4
			
			Vector2(0, 2): newPosition.x = 285.6
			Vector2(1, 2): newPosition.x = 361.6
			Vector2(2, 2): newPosition.x = 443.6
			Vector2(3, 2): newPosition.x = 524
			Vector2(4, 2): newPosition.x = 604.4
			Vector2(5, 2): newPosition.x = 682.8
			
			Vector2(0, 3): newPosition.x = 268.4
			Vector2(1, 3): newPosition.x = 350.4
			Vector2(2, 3): newPosition.x = 438.4
			Vector2(3, 3): newPosition.x = 526
			Vector2(4, 3): newPosition.x = 612.6
			Vector2(5, 3): newPosition.x = 697.2
			
			Vector2(0, 4): newPosition.x = 251.2
			Vector2(1, 4): newPosition.x = 339.2
			Vector2(2, 4): newPosition.x = 433.2
			Vector2(3, 4): newPosition.x = 528
			Vector2(4, 4): newPosition.x = 620.8
			Vector2(5, 4): newPosition.x = 711.6
			
			Vector2(0, 5): newPosition.x = 234
			Vector2(1, 5): newPosition.x = 328
			Vector2(2, 5): newPosition.x = 428
			Vector2(3, 5): newPosition.x = 530
			Vector2(4, 5): newPosition.x = 628
			Vector2(5, 5): newPosition.x = 726
		
	# Anyway! Now that the new position has been calculated...
	# Adjust the object's ACTUAL position to match.
	# Tweens don't work here because those are for *animation frames.*
	# That means, for smooth movement, we need to calculate velocity instead.
	var xDifference = newPosition.x - position.x
	var yDifference = newPosition.y - position.y
	
	if -0.5 < xDifference && 0.5 > xDifference: velocity.x = xDifference
	else: velocity.x = xDifference / 5
	
	if -0.5 < yDifference && 0.5 > yDifference: velocity.y = yDifference
	else: velocity.y = yDifference / 5
		
	position += Vector2(velocity.x, velocity.y)