# Generic enemy class for standard battles.
# I'm *fairly* sure most methods will be handled here or in Battle scripts;
# inheritors will mostly just contain info on abilities, animations, et cetera.
extends Node2D
class_name EnemyEntity

# Point to the parent node, i.e. the Battlefield.
onready var parent = get_parent()

# This class SHOULD behave as an enemy (usually).
var isEnemy = true

# Create an empty Velocity vector, which defaults to zero.
# We use this to smoothly move the character across the screen.
var velocity = Vector2.ZERO
# TARGET position tracker. Distinct from "position" for the purposes of velocity calculations.
var newPosition = Vector2.ZERO

# Where is the character on the battlefield grid?
# (Starting location is decided on a per-battle basis.)
var gridIndex

# Stats; these should be set in the individual enemy classes.
var maxHP
var currHP

var bleedResist
var currBleed
var paralResist
var currParal
var blindResist
var currBlind
var sealResist
var currSeal

var baseAttack
var baseDefense
var baseSpeed
# Separate magic stats?

# TO BE ADDED WHEN RELEVANT: Buff/debuff modifiers

# Lists of skills - separated into "special" abilities + regular attacks
var attackList
var specialList

# Track time until the character goes next
var timeToNextTurn

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Ensure that the character is at the correct z-index.
	z_index = gridIndex.y + 1
	
	# Scale the player. Default scale, at the back, is 0.75 times the normal values.
	# We want the maximum scale value to be 1.1, or +0.35 from the default
	# Since there are 6 x 64 tiles, that's a total distance of 384, and thus...
	var scaleFactor = 0.75 + (0.35 * (position.y - 320) / 384)
	scale.x = scaleFactor
	scale.y = scaleFactor
	
	# BELOW MAY OR MAY NOT CHANGE ONCE ENEMY AI IS DEVELOPED
	if parent.currentAction == "movement": movementHandler()

# This function is used to figure out where the enemy sprite should be.
# All of the code is the same as in PlayerCharacter.gd unless otherwise noted.
func movementHandler():
	newPosition.y = (0.75 * parent.map_to_world(gridIndex).y) + 100
	
	match gridIndex:
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
	
	var xDifference = newPosition.x - position.x
	var yDifference = newPosition.y - position.y
	
	if -0.5 < xDifference && 0.5 > xDifference: velocity.x = xDifference
	else: velocity.x = xDifference / 5
	
	if -0.5 < yDifference && 0.5 > yDifference: velocity.y = yDifference
	else: velocity.y = yDifference / 5
		
	position += Vector2(velocity.x, velocity.y)

# AI-only function: Check this enemy's "special" skills (supports + 'weird' attacks) to see if any should be used.
# All specific behavior will be defined per specific enemy. As such, the generic one will always return false.
func ai_specialSkillReview(charlist):
	print("Enemy has no special skills.")
	return false

# AI-only function: Check this enemy's regular attacks to see if any can be used.
# Always return the first match; attacks can be prioritized by reordering the array.
func ai_regAttackReview(charlist):
	var targetCharacter = false
	
	# Loop through every regular attack this enemy has, in order.
	for attack in attackList:
		# Loop through every tile that this attack can target.
		for targetableTile in attack.abilityRange:
			# Is there an enemy there? If so, and they're the first valid target - or they're a "better" target
			# than anyone else - set them as targetCharacter.
			# (By default, the enemy will target the weakest PC, but this can be changed - e.g. to make a specific
			# character an undesirable target.)
			for character in charlist:
				if not targetCharacter:
					if not character.isEnemy && character.gridIndex == gridIndex + targetableTile:
						targetCharacter = character
				elif targetCharacter.currHP < character.currHP:
					if not character.isEnemy && character.gridIndex == gridIndex + targetableTile:
						targetCharacter = character
		# If a valid target has been found, return them along with the attack that should be used.
		# Otherwise, proceed with the loop.
		if targetCharacter: return [attack, targetCharacter]
	
	# If we exit the loop without a valid target found for any attack, return false.
	return false

func ai_whereToMove(charlist):
	# First off: Which PC IS the closest?
	var targetCharacter = false
	
	for character in charlist:
		# First, target the first PC in the list.
		if not targetCharacter && not character.isEnemy: targetCharacter = character
		# Compare with subsequent PCs to see who's CLOSEST.
		elif (abs(gridIndex.x + gridIndex.y - character.gridIndex.x - character.gridIndex.y) 
			> abs(gridIndex.x + gridIndex.y - targetCharacter.gridIndex.y - targetCharacter.gridIndex.y) &&
			not character.isEnemy):
				targetCharacter = character
				
	# We've found who to "anchor" movement to, now figure out the best way to get closer.
	# 1. Are they closer horizontally, or vertically? 2. What direction are they in?
	if abs(gridIndex.x - targetCharacter.gridIndex.x) > abs(gridIndex.y - targetCharacter.gridIndex.y):
		if gridIndex.x > targetCharacter.gridIndex.x: gridIndex.x -= 1
		else: gridIndex.x += 1
	else:
		if gridIndex.y > targetCharacter.gridIndex.y: gridIndex.y -= 1
		else: gridIndex.y +=1
