# This class exists mostly to contain data which will be accessed by the Player and Battle
# scripts. Not sure if any methods will be included; if so, they will be rare.
extends Node
class_name CombatAbility

# Ability name and description
var abilityName
var abilityDesc

# Targeting parameters - minimum range, maximum range, what directions you can aim it
var minRange
var maxRange
var vertOK
var horizOK
var diagOK

# Figure out AoE attacks. Probably individual "areaVert," "areaHoriz," "areaDiag" parameters
# would be best, so that we can play around with differently "shaped" attacks

# How much damage / healing does the ability do?
var baseHPEffect

# Cooldown, if we need it?
# Icon, if we want it?

# Ability constructor, called by the relevant PC script to set up the ability.
func _init(abiName = "Dummy Ability", abiDesc = "Ability Description",
		abiMinRange = 1, abiMaxRange = 1, abiVert = true, abiHoriz = true, abiDiag = true,
		abiHPEffect = 0):
	abilityName = abiName
	abilityDesc = abiDesc
	minRange = abiMinRange
	maxRange = abiMaxRange
	vertOK = abiVert
	horizOK = abiHoriz
	diagOK = abiDiag
	baseHPEffect = abiHPEffect

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
