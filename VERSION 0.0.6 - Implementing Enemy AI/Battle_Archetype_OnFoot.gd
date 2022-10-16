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
var selectedAbility
# Used to track where the player is currently targeting
var reticleLoc = Vector2.ZERO
# When the player moves the reticle, this helps find a valid position for it
var newReticleLoc = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	# Seed the randomizer
	randomize()
	
	currentAction = "movement" # In a fancier version, we might instead set a timer before this kicks in.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Remove any defeated characters from characterArray.
	for character in characterArray:
		if character.currHP <= 0: 
			character.hide()
			characterArray.erase(character)
	
	# Register player input based on the current action being taken.
	match currentAction:
		"movement": movementHandler()
		"attack menu": attackMenuHandler()
		"support menu": supportMenuHandler()
		"attack targeting": moveTargetingHandler()
		"support targeting": moveTargetingHandler()

# This function handles moving a PLAYER CHARACTER across the battlefield.
# IT MAY EVENTUALLY HANDLE ENEMY MOVEMENT AS WELL - FIGURE THAT OUT
func movementHandler():
	if activeCharacter.isEnemy:
		# Change "current action" so that this method doesn't get called again next frame.
		currentAction = "processing"
		
		# Check if the enemy has any special skills they can/should use.
		var enemyAction = activeCharacter.ai_specialSkillReview(characterArray)
		if enemyAction: pass
		
		# IF NOT: Loop through all regular attacks and use the first valid one.
		# (Attack priority can thus be altered by reordering them in the enemy script.)
		enemyAction = activeCharacter.ai_regAttackReview(characterArray)
		if enemyAction:
			# Display range of ability, targeting reticle.
			reticleLoc = enemyAction[1].gridIndex
			selectedAbility = enemyAction[0]
			displayAbilityRange(false, true)
			
			# Okay now actually use the ability.
			# This code is all copied from moveTargetingHandler, modified slightly since the player doesn't
			# input anything.
			var valid_targets = []
		
			# Loop through characterArray, making a note of all valid targets.
			# (Since this is a regular attack, that will ALWAYS include PCs; it will also include NPCs
			# if the attack can hit them)
			for character in characterArray:
				for tile in selectedAbility.areaOfEffect:
					if (tile + reticleLoc == character.gridIndex && (not character.isEnemy ||
						(character.isEnemy && selectedAbility.targetsAllies))): 
						valid_targets.append(character)
			
			# Note that we don't need to confirm if at least one valid target exists - we already did that!
			
			# Animate the ability. For more complicated animations, we'll probably need to use an
			# AnimationPlayer node, maybe timers as well.
			# But for now, we just need a quick default animation, so let's use a hacky solution.
			var animSprite = activeCharacter.playAnim(selectedAbility.assocAnimation)
			yield(animSprite, "animation_finished")
			animSprite.play("default")
			
			# Apply the effect of the chosen ability to all valid targets
			# DOES NOT YET FACTOR IN BUFFS/DEBUFFS
			for target in valid_targets:
				target.currHP += int(selectedAbility.hpFactor * ((randi() % 16) + 10 + 
					(activeCharacter.baseAttack * activeCharacter.baseAttack / target.baseDefense)))
				
				# Target HP should never exceed their maximum HP
				if target.currHP > target.maxHP: target.currHP = target.maxHP
				# If the target's HP goes below zero, they should be killed/KO'd... but we haven't
				# implemented that, so for now, just use a print function.
				print(target.charName + " has: " + str(target.currHP) + " HP")
				if target.currHP < 0: print("They're dead now!")
			
			# TO BE DONE: Figure out how to "maintain position" until all animations have played
			# out. Otherwise, we essentially erase the highlighted tiles right after drawing them.
			
			# Erase all highlighted tiles
			for xVal in range(6):
				for yVal in range(6): set_cellv(Vector2(xVal, yVal), 0)
			
			# Update character's action cooldown and, if necessary, move down the turn order
			adjustActionTimer(selectedAbility.t_cooldown)
			
			# Exit function.
			currentAction = "movement"
			return
		
		# IF NO VALID SPECIAL SKILLS *OR* REGULAR ATTACKS EXIST: The enemy's range is all fucked!
		# Clearly, they should move.
		currentAction = "movement"
		activeCharacter.ai_whereToMove(characterArray)
		adjustActionTimer(15)
		return
		
	# Draw a "cursor tile" in the player's current position
	set_cellv(activeCharacter.gridIndex, 1)
	# First things first: If they select the ATTACK or SUPPORT menu, end this method and switch phases.
	if Input.is_action_pressed("open_attack_menu") && canInput:
		set_cellv(activeCharacter.gridIndex, 0)
		currentAction = "attack menu"
		# Display the cursor and the attack-skill menu.
		# TBD? - move this to a PopupMenuHandler script and get it all nicely encapsulated
		$PopupMenuHandler/SelectionCursor.show()
		$PopupMenuHandler/Attack_Menu.show()
		inputLock()
		
	elif Input.is_action_pressed("open_support_menu") && canInput:
		set_cellv(activeCharacter.gridIndex, 0)
		currentAction = "support menu"
		# Display the cursor and the support-skill menu.
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
	
	# Expend a small amount of time per movement
	adjustActionTimer(15)

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
		selectedAbility = activeCharacter.attackList[menuCursorIndex]
		currentAction = "attack targeting"
		displayAbilityRange(true)
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
	# (If there's no option in that direction, the cursor index should not be changed.)
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
	# When the user selects an ability, move to the targeting phase
	elif Input.is_action_pressed("ui_accept"):
		selectedAbility = activeCharacter.supportList[menuCursorIndex]
		currentAction = "support targeting"
		displayAbilityRange(true)
		# Hide the cursor and the attack-skill menu
		$PopupMenuHandler/SelectionCursor.hide()
		$PopupMenuHandler/Support_Menu.hide()
		inputLock()

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

# Display the selected ability's range and AoE. Optionally: initialize the targeting reticle.
func displayAbilityRange(initReticle = false, overrideTargetTile = false):
	# Clear out all tiles
	for xVal in range(6):
		for yVal in range(6): set_cellv(Vector2(xVal, yVal), 0)
	
	# Find the valid tiles in the ability's RANGE.
	for tile in selectedAbility.abilityRange:
		# IF that location is WITHIN THE BATTLEFIELD'S BOUNDARIES, highlight it.
		if ((tile.x + activeCharacter.gridIndex.x >= 0) && 
			(tile.x + activeCharacter.gridIndex.x <= 5) &&
			(tile.y + activeCharacter.gridIndex.y >= 0) && 
			(tile.y + activeCharacter.gridIndex.y <= 5)):
			set_cellv(activeCharacter.gridIndex + tile, 1)
			# Set the default reticle location to this tile.
			# Strictly speaking, we don't HAVE to do this every time, but this is probably the simplest
			# (and fastest) option.
			newReticleLoc = activeCharacter.gridIndex + tile
	# If we're showing this range FOR THE FIRST TIME, place the reticle at a default location.
	# (We include this "if" statement so that we can call this method repeatedly to re-draw the range,
	# even if the reticle has moved.)
	if initReticle: 
		reticleLoc = newReticleLoc
		# Generic "non-targeting" version of reticle for Donut abilities etc?
	# Now, mark all tiles in the ability's AREA OF EFFECT.
	for tile in selectedAbility.areaOfEffect:
		if ((tile.x + reticleLoc.x >= 0) && 
			(tile.x + reticleLoc.x <= 5) &&
			(tile.y + reticleLoc.y >= 0) && 
			(tile.y + reticleLoc.y <= 5)):
				if get_cellv(reticleLoc + tile) == 1 && not overrideTargetTile:
					set_cellv(reticleLoc + tile, 2)
				else: set_cellv(reticleLoc + tile, 3)

# This function handles finding a target for an ability, regardless of if it's an attack or support ability.
# It could also handle item targeting if that ever becomes a going concern.
func moveTargetingHandler():
	if not canInput: return # No need to check for input if inputs are locked.
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
	# If the player presses any "move" key, adjust the reticle's position.
	if Input.is_action_pressed("move_left"):
		# Place newReticleLoc one tile to the left of reticleLoc
		newReticleLoc = Vector2(reticleLoc.x - 1, reticleLoc.y)
		
		# Loop through possible locations, moving to the left each time, until we:
		# 1. reach the end of the battlefield or 2. find a valid target tile.
		var validTileFound = false
		while not validTileFound:
			# Have we exceeded the limits of the battlefield? If so...
			if newReticleLoc.x < 0:
				# First, check if we're "lined up" with the player. If not, adjust yIndex and try again.
				if newReticleLoc.y > activeCharacter.gridIndex.y:
					newReticleLoc = Vector2(reticleLoc.x - 1, newReticleLoc.y - 1)
				elif newReticleLoc.y < activeCharacter.gridIndex.y:
					newReticleLoc = Vector2(reticleLoc.x - 1, newReticleLoc.y + 1)
				# If so, we've eliminated all valid leftward movement. Exit loop without adjusting reticle.
				else: return
			# If we haven't exceeded the battlefield: Is this a valid tile to move to?
			elif (newReticleLoc - activeCharacter.gridIndex) in selectedAbility.abilityRange:
				inputLock(1)
				validTileFound = true
			# If not, shift newReticleLoc left and try again.
			else:
				newReticleLoc.x -= 1
			
		# If we're here, a valid tile has been found. Update reticleLoc and redraw range and AOE.
		reticleLoc = newReticleLoc
		displayAbilityRange()
		# Don't forget to lock down input for a moment.
		inputLock()
	# Moving right works the same as moving left, but with some of the signs flipped
	if Input.is_action_pressed("move_right"):
		newReticleLoc = Vector2(reticleLoc.x + 1, reticleLoc.y)

		var validTileFound = false
		while not validTileFound:
			if newReticleLoc.x > 5:
				if newReticleLoc.y > activeCharacter.gridIndex.y:
					newReticleLoc = Vector2(reticleLoc.x + 1, newReticleLoc.y - 1)
				elif newReticleLoc.y < activeCharacter.gridIndex.y:
					newReticleLoc = Vector2(reticleLoc.x + 1, newReticleLoc.y + 1)
				else: return
			elif (newReticleLoc - activeCharacter.gridIndex) in selectedAbility.abilityRange:
				inputLock(1)
				validTileFound = true
			else:
				newReticleLoc.x += 1
			
		reticleLoc = newReticleLoc
		displayAbilityRange()

		inputLock()
	# Up and down are also the same, but with "x" and "y" flipped
	if Input.is_action_pressed("move_up"):
		newReticleLoc = Vector2(reticleLoc.x, reticleLoc.y - 1)
		
		var validTileFound = false
		while not validTileFound:
			if newReticleLoc.y < 0:
				if newReticleLoc.x > activeCharacter.gridIndex.x:
					newReticleLoc = Vector2(newReticleLoc.x - 1, reticleLoc.y - 1)
				elif newReticleLoc.x < activeCharacter.gridIndex.x:
					newReticleLoc = Vector2(newReticleLoc.x + 1, reticleLoc.y - 1)
				else: return
			elif (newReticleLoc - activeCharacter.gridIndex) in selectedAbility.abilityRange:
				inputLock(1)
				validTileFound = true
			else:
				newReticleLoc.y -= 1
			
		reticleLoc = newReticleLoc
		displayAbilityRange()

		inputLock()
	if Input.is_action_pressed("move_down"):
		newReticleLoc = Vector2(reticleLoc.x, reticleLoc.y + 1)
		
		var validTileFound = false
		while not validTileFound:
			if newReticleLoc.y > 5:
				if newReticleLoc.x > activeCharacter.gridIndex.x:
					newReticleLoc = Vector2(newReticleLoc.x - 1, reticleLoc.y + 1)
				elif newReticleLoc.x < activeCharacter.gridIndex.x:
					newReticleLoc = Vector2(newReticleLoc.x + 1, reticleLoc.y + 1)
				else: return
			elif (newReticleLoc - activeCharacter.gridIndex) in selectedAbility.abilityRange:
				inputLock(1)
				validTileFound = true
			else:
				newReticleLoc.y += 1
			
		reticleLoc = newReticleLoc
		displayAbilityRange()

		inputLock()
	# If the player presses the "confirm" key, attempt to use the ability.
	if Input.is_action_pressed("ui_accept"):
		var valid_targets = []
		
		# Loop through characterArray, making a note of all valid targets
		for character in characterArray:
			for tile in selectedAbility.areaOfEffect:
				if (tile + reticleLoc == character.gridIndex &&
				   ((selectedAbility.targetsAllies && not character.isEnemy) ||
					(selectedAbility.targetsEnemies && character.isEnemy))): valid_targets.append(character)
		
		# If no valid targets have been found, return.
		if valid_targets.size() == 0:
			inputLock()
			return
		# Otherwise, confirm the ability and move forward
		else:
			### In a full game, you'll want to call player animation code here
			
			# Apply the effect of the chosen ability to all valid targets
			# DOES NOT YET FACTOR IN BUFFS/DEBUFFS
			for target in valid_targets:
				target.currHP += int(selectedAbility.hpFactor * ((randi() % 16) + 10 + 
					(activeCharacter.baseAttack * activeCharacter.baseAttack / target.baseDefense)))
				
				# Target HP should never exceed their maximum HP
				if target.currHP > target.maxHP: target.currHP = target.maxHP
				# If the target's HP goes below zero, they should be killed/KO'd... but we haven't
				# implemented that, so for now, just use a print function.
				print(target.currHP)
				if target.currHP < 0: print("They're dead now!")
			
			# Erase all highlighted tiles
			for xVal in range(6):
				for yVal in range(6): set_cellv(Vector2(xVal, yVal), 0)
			
			# Update character's action cooldown and, if necessary, move down the turn order
			adjustActionTimer(selectedAbility.t_cooldown)
			
			# Reset the cursor index and location
			menuCursorIndex = 0
			$PopupMenuHandler/SelectionCursor.position = Vector2(47, 63)
			
			# Lock input and switch to the movement phase
			inputLock()
			currentAction = "movement"

# Use this method whenever a character acts in order to determine when they get to act next.
# THIS CODE MAY NEED TO BE REFACTORED AS COMBAT IS REFINED.
func adjustActionTimer(action_time_value = 15):
	activeCharacter.timeToNextTurn += action_time_value
	for character in characterArray:
		# Decrement timeToNextTurn by the speed value.
		# TO BE ADDED WHEN RELEVANT: Factor in buff/debuff modifiers
		character.timeToNextTurn -= character.baseSpeed
		
		# Switch over to the character with the lowest wait time.
		# THIS IS NOT HOW WE WILL DO THINGS IN THE LONG TERM!!
		if character.timeToNextTurn < activeCharacter.timeToNextTurn: activeCharacter = character
	
	# Repopulate abilities
	print("Active character is now: " + str(activeCharacter.charName) + ", " + str(activeCharacter.timeToNextTurn))
	if not activeCharacter.isEnemy: populateSkillMenus()

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
