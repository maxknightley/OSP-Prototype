extends TileMap
class_name Encounter_OnFoot

var canInput = true # We'll use this to avoid receiving multiple inputs from a single keypress.

var isFieldCursorVisible = false # Use this to determine when to draw a "target" tile.
var menuCursorIndex = 0 # Use this to determine what option the player is selecting from a menu.

# Current action - i.e., movement, idle, selecting a target, using a particular menu
var currentAction

# Array of characters in the battle
var characterArray = []
# Current turn belongs to?
var activeCharacter

# When the player selects an ability to use, it's recorded here
var selectedAction
# What tile is the player targeting?
var actionTargetIndex = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	currentAction = "movement" # In a fancier version, we might instead set a timer before this kicks in.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Register player input based on the current action being taken.
	match currentAction:
		"movement": playerMovementHandler()
		"attack menu": attackMenuHandler()
		"support menu": supportMenuHandler()
		"attack targeting": targetActionHandler()
		"support targeting": targetActionHandler()

# This function handles moving a PLAYER CHARACTER across the battlefield.
func playerMovementHandler():
	# Draw a "cursor tile" in the player's current position
	set_cellv(activeCharacter.gridIndex, 1)
	# First things first: If they select the ATTACK or SUPPORT menu, end this method and switch phases.
	if Input.is_action_pressed("open_attack_menu") && canInput:
		set_cellv(activeCharacter.gridIndex, 0)
		currentAction = "attack menu"
		# Display the cursor and the attack-skill menu
		$PopupMenuHandler/SelectionCursor.show()
		$PopupMenuHandler/Attack_Menu.show()
		inputLock()
		
	elif Input.is_action_pressed("open_support_menu") && canInput:
		set_cellv(activeCharacter.gridIndex, 0)
		currentAction = "support menu"
		# Display the cursor and the support-skill menu
		$PopupMenuHandler/SelectionCursor.show()
		$PopupMenuHandler/Support_Menu.show()
		inputLock()
	
	var activePlayerTargetPosition = activeCharacter.gridIndex
	
	# If you're going to be right behind another character, make them
	# semi-transparent so you can see yourself better.
	# NOTE: If we do include Extra Large characters, like in LAL proper, we'll either have
	# to rework a lot of things... or program them as though they were MULTIPLE characters,
	# linked together. This is one of them. We'll deal with that when we deal with it.
	for character in characterArray:
		if (character != activeCharacter &&
			(character.gridIndex.x == activePlayerTargetPosition.x) && 
			(character.gridIndex.y == activePlayerTargetPosition.y + 1)):
			character.modulate.a = 0.5
		else: character.modulate.a = 1.0
	
	# If they press an arrow key, adjust the "target position" for the cursor.
	if Input.is_action_pressed("move_right") && canInput:
		activePlayerTargetPosition.x += 1
	if Input.is_action_pressed("move_left") && canInput:
		activePlayerTargetPosition.x -= 1
	if Input.is_action_pressed("move_down") && canInput:
		activePlayerTargetPosition.y += 1
	if Input.is_action_pressed("move_up") && canInput:
		activePlayerTargetPosition.y -= 1
	
	# Now... Is that a valid tile to move to?
	# First, check if the tile exists in the grid.
	if get_cellv(activePlayerTargetPosition) != -1:
		
		# Now, loop through the other characters to make sure you're not trying
		# to move to an occupied square (or the square you're already on).
		for character in characterArray:
			if activePlayerTargetPosition == character.gridIndex: return
		
		# Disable blinking cursor at their "old" location
		set_cellv(activeCharacter.gridIndex, 0)
		# Update player's grid index
		activeCharacter.gridIndex = activePlayerTargetPosition
	else: return
	
	# If the target position was succesfully changed, call inputLock.
	# We do this HERE so that the controls don't become unresponsive after an invalid move.
	inputLock()
		
	# DUMMY CODE - TO BE CHANGED - Switch over to the next player character.
	if(activeCharacter.charName == "Baqi"):
		# Change the active character.
		activeCharacter = characterArray[1]
		
		# Set up ability text
		populateSkillMenus()
	elif(activeCharacter.charName == "Ra'Kit"): 
		activeCharacter = characterArray[2]
		
		populateSkillMenus()
	else:
		activeCharacter = characterArray[0]
		
		populateSkillMenus()

# This function handles selecting an offensive ability from the attack menu.
func attackMenuHandler():
	if not canInput: return # No need to check for input if inputs are locked.
	# If the player hits the cancel button, close the menu and return to the movement phase.
	if Input.is_action_pressed("ui_cancel") && not Input.is_action_pressed("open_attack_menu"):
		# Hide the cursor and the attack-skill menu
		$PopupMenuHandler/SelectionCursor.hide()
		$PopupMenuHandler/Attack_Menu.hide()
		# Reset the cursor index and location
		menuCursorIndex = 0
		$PopupMenuHandler/SelectionCursor.position = Vector2(47, 63)
		# Return to the movement phase
		currentAction = "movement"
		inputLock()
		return
	# If the user hits a direction, move the cursor.
	# (If there's no option in that direction, the cursor index should not be changed.)
	if (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")):
		if menuCursorIndex % 2 == 1:
			$PopupMenuHandler/SelectionCursor.position.x -= 488
			menuCursorIndex -= 1
		elif menuCursorIndex < activeCharacter.attackList.size() - 1:
			$PopupMenuHandler/SelectionCursor.position.x += 488
			menuCursorIndex += 1
		inputLock()
	elif (Input.is_action_pressed("move_down") && 
		menuCursorIndex < activeCharacter.attackList.size() - 2):
		$PopupMenuHandler/SelectionCursor.position.y += 50
		menuCursorIndex += 2
		inputLock()
	elif Input.is_action_pressed("move_up") && menuCursorIndex > 1:
		$PopupMenuHandler/SelectionCursor.position.y -= 50
		menuCursorIndex -= 2
		inputLock()
	# When the user selects an ability, move to the targeting phase
	elif Input.is_action_pressed("ui_accept"):
		selectedAction = activeCharacter.attackList[menuCursorIndex]
		currentAction = "attack targeting"
		targetActionInitializer()
		# Hide the cursor and the attack-skill menu
		$PopupMenuHandler/SelectionCursor.hide()
		$PopupMenuHandler/Attack_Menu.hide()
		inputLock()

# Ditto for this but it's support abilities
func supportMenuHandler():
	if not canInput: return
	if Input.is_action_pressed("ui_cancel") && not Input.is_action_pressed("open_support_menu"):
		# Hide the cursor and the support-skill menu
		$PopupMenuHandler/SelectionCursor.hide()
		$PopupMenuHandler/Support_Menu.hide()
		# Reset the cursor index and location
		menuCursorIndex = 0
		$PopupMenuHandler/SelectionCursor.position = Vector2(47, 63)
		# Return to the movement phase
		currentAction = "movement"
		inputLock()
		return
	# If the user hits a direction, move the cursor.
	if (Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")):
		if menuCursorIndex % 2 == 1:
			$PopupMenuHandler/SelectionCursor.position.x -= 488
			menuCursorIndex -= 1
		elif menuCursorIndex < activeCharacter.supportList.size() - 1:
			$PopupMenuHandler/SelectionCursor.position.x += 488
			menuCursorIndex += 1
		inputLock()
	elif (Input.is_action_pressed("move_down") && 
		menuCursorIndex < activeCharacter.supportList.size() - 2):
		$PopupMenuHandler/SelectionCursor.position.y += 50
		menuCursorIndex += 2
		inputLock()
	elif Input.is_action_pressed("move_up") && menuCursorIndex > 1:
		$PopupMenuHandler/SelectionCursor.position.y -= 50
		menuCursorIndex -= 2
		inputLock()
	# If the user selects an ability, record it and move to the targeting phase.
	elif Input.is_action_pressed("ui_accept"):
		selectedAction = activeCharacter.supportList[menuCursorIndex]
		currentAction = "support targeting"
		targetActionInitializer()
		# Hide the cursor and the support-skill menu
		$PopupMenuHandler/SelectionCursor.hide()
		$PopupMenuHandler/Support_Menu.hide()
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

# Update the attack and support-skill menus to reflect this character's abilities.
# I am almost certain there's a cleaner way to do this, but if it works, it works.
func populateSkillMenus():
	
	var attackListSize = activeCharacter.attackList.size()
	var supportListSize = activeCharacter.supportList.size()
	
	$PopupMenuHandler/Attack_Menu/Attack1.text = activeCharacter.attackList[0].abilityName
	if attackListSize > 1: $PopupMenuHandler/Attack_Menu/Attack2.text = activeCharacter.attackList[1].abilityName
	else: $PopupMenuHandler/Attack_Menu/Attack2.text = ""
	if attackListSize > 2: $PopupMenuHandler/Attack_Menu/Attack3.text = activeCharacter.attackList[2].abilityName
	else: $PopupMenuHandler/Attack_Menu/Attack3.text = ""
	if attackListSize > 3: $PopupMenuHandler/Attack_Menu/Attack4.text = activeCharacter.attackList[3].abilityName
	else: $PopupMenuHandler/Attack_Menu/Attack4.text = ""
	
	$PopupMenuHandler/Support_Menu/S_Skill1.text = activeCharacter.supportList[0].abilityName
	if supportListSize > 1: $PopupMenuHandler/Support_Menu/S_Skill2.text = activeCharacter.supportList[1].abilityName
	else: $PopupMenuHandler/Support_Menu/S_Skill2.text = ""
	if supportListSize > 2: $PopupMenuHandler/Support_Menu/S_Skill3.text = activeCharacter.supportList[2].abilityName
	else: $PopupMenuHandler/Support_Menu/S_Skill3.text = ""
	if supportListSize > 3: $PopupMenuHandler/Support_Menu/S_Skill4.text = activeCharacter.supportList[3].abilityName
	else: $PopupMenuHandler/Support_Menu/S_Skill4.text = ""

# This function handles finding a target for an ability, regardless of if it's an attack or support ability.
func targetActionHandler():
	# If the player cancels out, de-highlight all tiles and return to the previous menu.
	if Input.is_action_pressed("ui_cancel"):
		for xVal in range(6):
			for yVal in range(6): set_cellv(Vector2(xVal, yVal), 0)
		
		if currentAction == "attack targeting":
			currentAction = "attack menu"
			$PopupMenuHandler/SelectionCursor.show()
			$PopupMenuHandler/Attack_Menu.show()
		else: 
			currentAction = "support menu"
			$PopupMenuHandler/SelectionCursor.show()
			$PopupMenuHandler/Support_Menu.show()
		inputLock()
	# Cursor movement
	if Input.is_action_pressed("move_left") && (selectedAction.horizOK || selectedAction.diagOK):
		# Find the position EXACTLY one to the left of the reticle.
		var i = actionTargetIndex.x - 1
		# We want to find a value of "i" which is either to the RIGHT of the ability's minimum range,
		# or to the LEFT of the ability's minimum range.
		# Keep trying out values and reducing i until we either hit the edge of the battlefield or find a good x-val.
		while ((i < activeCharacter.gridIndex.x + selectedAction.minRange) && 
			(i > activeCharacter.gridIndex.x - selectedAction.minRange)):
			i -= 1
		# Make sure that we haven't exceeded maxRange or the boundaries of the battlefield.
		if (i < 0) || (i < activeCharacter.gridIndex.x - selectedAction.maxRange): return
		# If that check passes, adjust the reticle accordingly.
		set_cellv(actionTargetIndex, 1)
		actionTargetIndex = Vector2(i, actionTargetIndex.y)
		set_cellv(actionTargetIndex, 2)
		inputLock()
	# Moving to the right works similarly, but with some of the negatives flipped to positive
	if Input.is_action_pressed("move_right") && (selectedAction.horizOK || selectedAction.diagOK):
		# Looking for a position to the right instead of the left
		var i = actionTargetIndex.x + 1
		# Same basic while loop, but we INCREASE i
		while ((i < activeCharacter.gridIndex.x + selectedAction.minRange) && 
			(i > activeCharacter.gridIndex.x - selectedAction.minRange)):
			i += 1
		# Make sure that we haven't exceeded maxRange or the boundaries of the battlefield.
		if (i > 6) || (i > activeCharacter.gridIndex.x + selectedAction.maxRange): return
		# If that check passes, adjust the reticle accordingly.
		set_cellv(actionTargetIndex, 1)
		actionTargetIndex = Vector2(i, actionTargetIndex.y)
		set_cellv(actionTargetIndex, 2)
		inputLock()
	# Moving up and down works the same as the last two, but with y-values instead of x-values
	if Input.is_action_pressed("move_up") && (selectedAction.vertOK || selectedAction.diagOK):
		var i = actionTargetIndex.y - 1
		while ((i < activeCharacter.gridIndex.y + selectedAction.minRange) && 
			(i > activeCharacter.gridIndex.y - selectedAction.minRange)):
			i -= 1
		# Make sure that we haven't exceeded maxRange or the boundaries of the battlefield.
		if (i < 0) || (i < activeCharacter.gridIndex.y - selectedAction.maxRange): return
		# If that check passes, adjust the reticle accordingly.
		set_cellv(actionTargetIndex, 1)
		actionTargetIndex = Vector2(actionTargetIndex.x, i)
		set_cellv(actionTargetIndex, 2)
		inputLock()

# When an ability is first selected from the menu, display its range and the targeting reticle.
# This function handles finding a target for an ability, regardless of if it's an attack or support ability.
func targetActionInitializer():
	var currTile = activeCharacter.gridIndex
	var maxR = selectedAction.maxRange
	var minR = selectedAction.minRange
	
	# Display the ability's range on the battlefield.
	# NOTE: This will NOT highlight the tile the player is on, even if minRange is zero.
	# That's fine, because we'll do that later.
	if selectedAction.horizOK:
		for i in range(maxR):
			if i+1 >= minR && get_cellv(currTile + Vector2(i+1, 0)) != -1:
				set_cellv(currTile + Vector2(i+1, 0), 1)
			if i+1 >= minR && get_cellv(currTile - Vector2(i+1, 0)) != -1:
				set_cellv(currTile - Vector2(i+1, 0), 1)
	if selectedAction.vertOK:
		for i in range(maxR):
			if i+1 >= minR && get_cellv(currTile + Vector2(0, i+1)) != -1:
				set_cellv(currTile + Vector2(0, i+1), 1)
			if i+1 >= minR && get_cellv(currTile - Vector2(0, i+1)) != -1:
				set_cellv(currTile - Vector2(0, i+1), 1)
	if selectedAction.diagOK:
		for i in range(maxR):
			if i+1 >= minR && get_cellv(currTile + Vector2(i+1, i+1)) != -1:
				set_cellv(currTile + Vector2(i+1, i+1), 1)
			if i+1 >= minR && get_cellv(currTile - Vector2(i+1, i+1)) != -1:
				set_cellv(currTile - Vector2(i+1, i+1), 1)
			if i+1 >= minR && get_cellv(currTile + Vector2(i+1, -i - 1)) != -1:
				set_cellv(currTile + Vector2(i+1, -i - 1), 1)
			if i+1 >= minR && get_cellv(currTile - Vector2(i+1, -i - 1)) != -1:
				set_cellv(currTile - Vector2(i+1, -i - 1), 1)
	
	# Determine default target.
	if minR == 0: 
		actionTargetIndex = currTile
	elif selectedAction.horizOK:
		if get_cellv(currTile + Vector2(1, 0)) != -1: actionTargetIndex = currTile + Vector2(minR, 0)
		else: actionTargetIndex = currTile - Vector2(minR, 0)
	elif selectedAction.vertOK:
		if get_cellv(currTile + Vector2(0, 1)) != -1: actionTargetIndex = currTile + Vector2(0, minR)
		else: actionTargetIndex = currTile - Vector2(0, minR)
	else: actionTargetIndex = currTile + Vector2(minR, minR)
	
	# Place the targeting reticle in the default position.
	set_cellv(actionTargetIndex, 2)