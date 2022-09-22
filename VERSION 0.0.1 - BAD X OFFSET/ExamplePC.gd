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
		# First, we set up a temporary variable where we'll calculate the player's target position.
		newPosition = parent.map_to_world(parent.cursorPosition)
	
		# Adjust newPosition so that PC will be center-aligned along the Y-Axis
		newPosition.y += 32
	
		### ALL OF THE FOLLOWING CHUNK HAS BEEN DEPRECATED. IGNORE IT WHILE WE TRY AND FIND A BETTER SOLUTION
		# We need to adjust the x-position to account for the perspective of the battlefield.
		# As y increases, we need to increase the MULTIPLIER of the x-adjustment.
		# This can *mostly* be handled via scaleFactor or a factor thereof.
		# We also need to account for HOW FAR the x-adjustment is from the CENTER LINE: x-coordinate 512.
	
		# (position.x - 512) / 640 gets us a float based on the cell position relative to the center of the grid.
		# By adding 0.1 to non-negative results, we ensure that the result is never 0... similar to our shader code!
	#	var x_tile_index = (newPosition.x - 512) / 640
	#	if x_tile_index >= 0: x_tile_index += 0.1
	
		# If, like in the shader, we adjust x by x_tile_index times the y position...
		# position.x += x_tile_index * position.y
		# We get a result that's way too high. Let's lower it a bit.
	
		# position.x += x_tile_index * position.y * 0.1
		# This works okay for the back, but it's no good for the front... Let's try working in the scaleFactor?
	
		#position.x += x_tile_index * position.y * (scaleFactor - 0.65)
		# This ALMOST works! It's better at the front than the back, and better at the right than the left.
		# So let's try...
	
		# newPosition.x += x_tile_index * newPosition.y * (scaleFactor - 0.6)
		# if x_tile_index < 0: newPosition.x += 14 / (scaleFactor + 0.35)
		# else: newPosition.x -= 14 * (scaleFactor * scaleFactor - 0.4)
	
		# This is really good at the center and in the front... but it needs a bit more finagling.
		# Problem areas are the back 1st column (too far left) and the back of columns 4-6 (WAY too far to the right).
		
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
