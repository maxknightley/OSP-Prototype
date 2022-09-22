extends TileMap

var cursorPosition = Vector2(0, 0)
var canMoveCursor = true # We'll use this to keep the cursor from moving too quickly.

# We would enumerate "Cell Types" IF we needed to differentiate between the contents of those cells.
# For example, we might note them as "EMPTY," "PLAYER," or "ENEMY."
# ...But we don't need that right now, figure it out later.
# enum CellType { ???, ???, ??? }

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the starting cursor position as a cursor tile
	set_cellv(cursorPosition, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var cursorTarget = cursorPosition
	
	# Register player input.
	# If they press an arrow key, adjust the "target position" for the cursor.
	if Input.is_action_pressed("move_right") && canMoveCursor:
		cursorTarget.x += 1
	if Input.is_action_pressed("move_left") && canMoveCursor:
		cursorTarget.x -= 1
	if Input.is_action_pressed("move_down") && canMoveCursor:
		cursorTarget.y += 1
	if Input.is_action_pressed("move_up") && canMoveCursor:
		cursorTarget.y -= 1
	
	# If the target position is unchanged, no further action required.
	if cursorTarget == cursorPosition: return
	# If it WAS changed, set a flag and a timer so the cursor will pause for a moment.
	# We set these AFTER the if statements in order to enable diagonal movement.
	else:
		canMoveCursor = false
		$MovementCooldown.start()
	
	# Now... Is that a valid tile to move to?
	if get_cellv(cursorTarget) != -1:
		# Change the old cursor position to a normal tile
		set_cellv(cursorPosition, 0)
		# Change the new cursor position to the cursor tile
		set_cellv(cursorTarget, 1)
		
		# Update cursor position variable
		cursorPosition = cursorTarget
		#print(map_to_world(cursorPosition))
		#print($ExamplePC.position.y)

# When the timer "ticks," the cursor gets unlocked
func _on_MovementCooldown_timeout():
	canMoveCursor = true
