# This class exists mostly to contain data which will be accessed by the Player and Battle
# scripts. Not sure if any methods will be included; if so, they will be rare.
extends Node
class_name CombatAbility

# Name and description of the ability.
var abilityName
var abilityDesc

# RANGE will be set up as an array of Vector2s. The details can be found within the constructor.
var abilityRange = []
# AoE works the same way.
var areaOfEffect = []

# After using the ability, how long should it take for the character to act again?
var t_cooldown
# "Charge up" time a la certain abilities in Live a Live?

# Affects damage or healing done by this ability - should generally be a float between 1.0 and 3.0
var hpFactor
# Damage types? [Slashing, Piercing, Splintering, Poisonous, Hot, Electric, etc.?]

# Icon, if we want it?

# Status effect type + damage, if necessary
var statusType
var statusDamage

# Buff/debuff type + power, if necessary
var buffType
var buffPercentage

# Ability constructor, called by the relevant PC script to set up the ability.
func _init(abiName = "Dummy Ability", abiDesc = "Ability Description", abiRange = "Self", abiAOE = "One Tile",
			abiCooldown = 50, abiHPF = 1.0,
			abiStatus = "None", abiStatDamage = 0, abiBuff = "None", abiBuffPct = 0):
	abilityName = abiName
	abilityDesc = abiDesc
	t_cooldown = abiCooldown
	hpFactor = abiHPF
	statusType = abiStatus
	statusDamage = abiStatDamage
	buffType = abiBuff
	buffPercentage = abiBuffPct
	
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
		"Melee Horizontal": 
			abilityRange.append(Vector2(1,0))
			abilityRange.append(Vector2(-1,0))
		"Melee Vertical":
			abilityRange.append(Vector2(0,1))
			abilityRange.append(Vector2(0,-1))
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
		"Knight":
			abilityRange.append(Vector2(1, 2))
			abilityRange.append(Vector2(2, 1))
			abilityRange.append(Vector2(1, -2))
			abilityRange.append(Vector2(2, -1))
			abilityRange.append(Vector2(-1, -2))
			abilityRange.append(Vector2(-2, -1))
			abilityRange.append(Vector2(-1, 2))
			abilityRange.append(Vector2(-2, 1))
		"Medium Area":
			# Top row
			abilityRange.append(Vector2(2, -2)) 
			abilityRange.append(Vector2(1, -2)) 
			abilityRange.append(Vector2(0, -2)) 
			abilityRange.append(Vector2(-1, -2))
			abilityRange.append(Vector2(-2, -2))  
			# Mid-top row
			abilityRange.append(Vector2(2, -1)) 
			abilityRange.append(Vector2(1, -1)) 
			abilityRange.append(Vector2(0, -1)) 
			abilityRange.append(Vector2(-1, -1))
			abilityRange.append(Vector2(-2, -1))
			# Mid-bottom row
			abilityRange.append(Vector2(2, 1)) 
			abilityRange.append(Vector2(1, 1)) 
			abilityRange.append(Vector2(0, 1)) 
			abilityRange.append(Vector2(-1, 1))
			abilityRange.append(Vector2(-2, 1))
			# Bottom row
			abilityRange.append(Vector2(2, 2)) 
			abilityRange.append(Vector2(1, 2)) 
			abilityRange.append(Vector2(0, 2)) 
			abilityRange.append(Vector2(-1, 2))
			abilityRange.append(Vector2(-2, 2))
			# Middle row
			abilityRange.append(Vector2(2, 0)) 
			abilityRange.append(Vector2(1, 0)) 
			abilityRange.append(Vector2(-1, 0))
			abilityRange.append(Vector2(-2, 0)) 

	# Similarly, Area of Effect is an array of Vec2s, representing "spaces relative to the targeting reticle."
	# For example, an ability can effect only the targeted tile, or a 3x3 square centered on the target...
	# These ones will also have names, for the same reason.
	match abiAOE:
		"One Tile":
			areaOfEffect.append(Vector2(0,0))
		"3x3":
			areaOfEffect.append(Vector2(0,0))
			areaOfEffect.append(Vector2(0,1))
			areaOfEffect.append(Vector2(1,1))
			areaOfEffect.append(Vector2(1,0))
			areaOfEffect.append(Vector2(1,-1))
			areaOfEffect.append(Vector2(0,-1))
			areaOfEffect.append(Vector2(-1,-1))
			areaOfEffect.append(Vector2(-1,0))
			areaOfEffect.append(Vector2(-1,1))
		"3 Column":
			areaOfEffect.append(Vector2(0,0))
			areaOfEffect.append(Vector2(0,1))
			areaOfEffect.append(Vector2(0,-1))
		"3 Row":
			areaOfEffect.append(Vector2(0,0))
			areaOfEffect.append(Vector2(1,0))
			areaOfEffect.append(Vector2(-1,0))
		"Small Donut": # Same as 3x3, but it doesn't affect the center tile
			areaOfEffect.append(Vector2(0,1))
			areaOfEffect.append(Vector2(1,1))
			areaOfEffect.append(Vector2(1,0))
			areaOfEffect.append(Vector2(1,-1))
			areaOfEffect.append(Vector2(0,-1))
			areaOfEffect.append(Vector2(-1,-1))
			areaOfEffect.append(Vector2(-1,0))
			areaOfEffect.append(Vector2(-1,1))
		"Plus-Cross":
			areaOfEffect.append(Vector2(0,0))
			areaOfEffect.append(Vector2(0,1))
			areaOfEffect.append(Vector2(0,-1))
			areaOfEffect.append(Vector2(1,0))
			areaOfEffect.append(Vector2(-1,0))
		"X-Cross":
			areaOfEffect.append(Vector2(0,0))
			areaOfEffect.append(Vector2(1,1))
			areaOfEffect.append(Vector2(1,-1))
			areaOfEffect.append(Vector2(-1,-1))
			areaOfEffect.append(Vector2(-1,1))

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
