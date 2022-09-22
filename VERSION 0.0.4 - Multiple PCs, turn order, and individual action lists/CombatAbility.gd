# This class exists mostly to contain data which will be accessed by the Player and Battle
# scripts. Not sure if any methods will be included; if so, they will be rare.
extends Node
class_name CombatAbility

# Name and description of the ability.
var abilityName
var abilityDesc

# RANGE will be set up as an array of Vector2s. The details can be found within the constructor.
var abilityRange = []

# Figure out Area of Effect - another array of vectors, probably?

# Cooldown, if we need it?
# Icon, if we want it?

# Ability constructor, called by the relevant PC script to set up the ability.
func _init(abiName = "Dummy Ability", abiDesc = "Ability Description", abiRange = "Self"):
	abilityName = abiName
	abilityDesc = abiDesc
	
	# An ability's range is an array of Vector2s, representing "spaces relative to the player."
	# For example, an ability targeting the player itself would have (0, 0) and that's it.
	# A "knight's leap" would include (1, 2); (2, -1); (-2, 1)... and so on.
	# Each of these will be named, so that we don't have to rewrite them for literally every ability in the game.
	match abiRange:
		"Self":
			abilityRange.append(Vector2(0,0))
		"Melee":
			abilityRange.append(Vector2(0,1))
			abilityRange.append(Vector2(0,-1))
			abilityRange.append(Vector2(1,1))
			abilityRange.append(Vector2(1,-1))
			abilityRange.append(Vector2(-1,1))
			abilityRange.append(Vector2(-1,-1))
			abilityRange.append(Vector2(1,0))
			abilityRange.append(Vector2(-1,0))
		"Melee Cardinal":
			abilityRange.append(Vector2(0,1))
			abilityRange.append(Vector2(0,-1))
			abilityRange.append(Vector2(1,0))
			abilityRange.append(Vector2(-1,0))
		"Long Range":
			# Diagonal
			abilityRange.append(Vector2(2, 2))
			abilityRange.append(Vector2(3, 3))
			abilityRange.append(Vector2(4, 4))
			abilityRange.append(Vector2(5, 5))
			abilityRange.append(Vector2(2, -2))
			abilityRange.append(Vector2(3, -3))
			abilityRange.append(Vector2(4, -4))
			abilityRange.append(Vector2(5, -5))
			abilityRange.append(Vector2(-2, 2))
			abilityRange.append(Vector2(-3, 3))
			abilityRange.append(Vector2(-4, 4))
			abilityRange.append(Vector2(-5, 5))
			abilityRange.append(Vector2(-2, -2))
			abilityRange.append(Vector2(-3, -3))
			abilityRange.append(Vector2(-4, -4))
			abilityRange.append(Vector2(-5, -5))
			# Vertical
			abilityRange.append(Vector2(0, 5))
			abilityRange.append(Vector2(0, 4))
			abilityRange.append(Vector2(0, 3))
			abilityRange.append(Vector2(0, 2))
			abilityRange.append(Vector2(0, -5))
			abilityRange.append(Vector2(0, -4))
			abilityRange.append(Vector2(0, -3))
			abilityRange.append(Vector2(0, -2))
			# Horizontal
			abilityRange.append(Vector2(5, 0))
			abilityRange.append(Vector2(4, 0))
			abilityRange.append(Vector2(3, 0))
			abilityRange.append(Vector2(2, 0))
			abilityRange.append(Vector2(-5, 0))
			abilityRange.append(Vector2(-4, 0))
			abilityRange.append(Vector2(-3, 0))
			abilityRange.append(Vector2(-2, 0))

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
