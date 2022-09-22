extends TileMap

var activePlayerPosition = Vector2(0, 0)
var canInput = true # We'll use this to avoid receiving multiple inputs from a single keypress.

var isFieldCursorVisible = false # Use this to determine when to draw a "target" tile.
var menuCursorIndex = 0 # Use this to determine what option the player is selecting from a menu.

# Current action - i.e., movement, idle, selecting a target, using a particular menu
var currentAction

# We would enumerate "Cell Types" IF we needed to differentiate between the contents of those cells.
# For example, we might note them as "EMPTY," "PLAYER," or "ENEMY."
# ...But we don't need that right now, figure it out later.
# enum CellType { ???, ???, ??? }

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	currentAction = "movement" # In a fancier version, we might instead set a timer before this kicks in.
	# Maybe initialize the turn order here?
	
	# Eventually, we'll need to populate both menus with the currently-selected PC's abilities,
	# once at the start of each turn. For now, we'll just add some dummy skills.
	$PopupMenuHandler/Attack1.text = "Dummy_A 1"
	$PopupMenuHandler/Attack2.text = "Dummy_A 2"
	$PopupMenuHandler/Attack3.text = "Dummy_A 3"
	$PopupMenuHandler/Attack4.text = "Dummy_A 4"
	$PopupMenuHandler/S_Skill1.text = "Dummy_S 1"
	$PopupMenuHandler/S_Skill2.text = "Dummy_S 2"
	$PopupMenuHandler/S_Skill3.text = "Dummy_S 3"
	$PopupMenuHandler/S_Skill4.text = "Dummy_S 4"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Register player input based on the current action being taken.
	match currentAction:
		"movement": playerMovementHandler()
		"attack menu": attackMenuHandler()
		"support menu": supportMenuHandler()

# This function handles moving a PLAYER CHARACTER across the battlefield.
func playerMovementHandler():
	# First things first: If they select the ATTACK or SUPPORT menu, end this method and switch phases.
	if Input.is_action_pressed("open_attack_menu") && canInput:
		currentAction = "attack menu"
		# Display the cursor, the background panel, and available ATTACKS.
		# TBD? - move this to a PopupMenuHandler script and get it all nicely encapsulated
		$PopupMenuHandler/SelectionCursor.show()
		$PopupMenuHandler/BG_Panel.show()
		$PopupMenuHandler/Attack1.show()
		$PopupMenuHandler/Attack2.show()
		$PopupMenuHandler/Attack3.show()
		$PopupMenuHandler/Attack4.show()
		inputLock()
		
	elif Input.is_action_pressed("open_support_menu") && canInput:
		currentAction = "support menu"
		# Display the cursor, the background panel, and available SUPPORT SKILLS.
		# TBD? - move this to a PopupMenuHandler script and get it all nicely encapsulated
		$PopupMenuHandler/SelectionCursor.show()
		$PopupMenuHandler/BG_Panel.show()
		$PopupMenuHandler/S_Skill1.show()
		$PopupMenuHandler/S_Skill2.show()
		$PopupMenuHandler/S_Skill3.show()
		$PopupMenuHandler/S_Skill4.show()
		inputLock()
	
	var activePlayerTargetPosition = activePlayerPosition
	
	# If they press an arrow key, adjust the "target position" for the cursor.
	if Input.is_action_pressed("move_right") && canInput:
		activePlayerTargetPosition.x += 1
	if Input.is_action_pressed("move_left") && canInput:
		activePlayerTargetPosition.x -= 1
	if Input.is_action_pressed("move_down") && canInput:
		activePlayerTargetPosition.y += 1
	if Input.is_action_pressed("move_up") && canInput:
		activePlayerTargetPosition.y -= 1
		
	# If the target position is unchanged, no further action required.
	if activePlayerTargetPosition == activePlayerPosition: return
	# If it WAS changed, set a flag and a timer so the cursor will pause for a moment.
	# We set these AFTER the if statements in order to enable diagonal movement.
	else: inputLock()
	
	# Now... Is that a valid tile to move to?
	if get_cellv(activePlayerTargetPosition) != -1:
		# Update cursor position variable
		activePlayerPosition = activePlayerTargetPosition

# This function handles selecting an offensive ability from the attack menu.
func attackMenuHandler():
	# If the player hits the cancel button, close the menu and return to the movement phase.
	if Input.is_action_pressed("ui_cancel") && canInput && not Input.is_action_pressed("open_attack_menu"):
		# Hide the cursor, the background panel, and available ATTACKS.
		# TBD? - move this to a PopupMenuHandler script and get it all nicely encapsulated
		$PopupMenuHandler/SelectionCursor.hide()
		$PopupMenuHandler/BG_Panel.hide()
		$PopupMenuHandler/Attack1.hide()
		$PopupMenuHandler/Attack2.hide()
		$PopupMenuHandler/Attack3.hide()
		$PopupMenuHandler/Attack4.hide()
		# Return to the movement phase
		currentAction = "movement"
		inputLock()
		return
	# If the user hits a direction, move the cursor.
	# TO BE ADDED: A "confirm" step to determine whether there's actually an option available.
	# (If not, the cursor index should not be adjusted and the position should not change.)
	if (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")) && canInput:
		if menuCursorIndex % 2 == 0:
			print("okay")
			$PopupMenuHandler/SelectionCursor.position.x += 488
			menuCursorIndex += 1
		else:
			$PopupMenuHandler/SelectionCursor.position.x -= 488
			menuCursorIndex -= 1
		inputLock()
	elif Input.is_action_pressed("move_down") && canInput:
		$PopupMenuHandler/SelectionCursor.position.y += 50
		menuCursorIndex += 2
		inputLock()
	elif Input.is_action_pressed("move_up") && canInput:
		$PopupMenuHandler/SelectionCursor.position.y -= 50
		menuCursorIndex -= 2
		inputLock()

# Ditto for this but it's support abilities
func supportMenuHandler():
	if Input.is_action_pressed("ui_cancel") && canInput && not Input.is_action_pressed("open_support_menu"):
		# Hide the cursor, the background panel, and available SUPPORT SKILLS.
		# TBD? - move this to a PopupMenuHandler script and get it all nicely encapsulated
		$PopupMenuHandler/SelectionCursor.hide()
		$PopupMenuHandler/BG_Panel.hide()
		$PopupMenuHandler/S_Skill1.hide()
		$PopupMenuHandler/S_Skill2.hide()
		$PopupMenuHandler/S_Skill3.hide()
		$PopupMenuHandler/S_Skill4.hide()
		# Return to the movement phase
		currentAction = "movement"
		inputLock()
		return
	# If the user hits a direction, move the cursor.
	# TO BE ADDED: A "confirm" step to determine whether there's actually an option available.
	# (If not, the cursor index should not be adjusted and the position should not change.)
	if (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")) && canInput:
		if menuCursorIndex % 2 == 0:
			print("okay")
			$PopupMenuHandler/SelectionCursor.position.x += 488
			menuCursorIndex += 1
		else:
			$PopupMenuHandler/SelectionCursor.position.x -= 488
			menuCursorIndex -= 1
		inputLock()
	elif Input.is_action_pressed("move_down") && canInput:
		$PopupMenuHandler/SelectionCursor.position.y += 50
		menuCursorIndex += 2
		inputLock()
	elif Input.is_action_pressed("move_up") && canInput:
		$PopupMenuHandler/SelectionCursor.position.y -= 50
		menuCursorIndex -= 2
		inputLock()

# Set a timer that momentarily prevents the game from receiving input.
# This is so we don't register repeat inputs from a single keypress.
# Wait time doesn't NEED to be adjusted in most cases, but it can if it benefits the feel.
func inputLock(time_to_wait = 0.28):
	canInput = false
	$MovementCooldown.wait_time = time_to_wait
	$MovementCooldown.start()

# When the timer "ticks," input is unlocked
func _on_MovementCooldown_timeout():
	canInput = true
