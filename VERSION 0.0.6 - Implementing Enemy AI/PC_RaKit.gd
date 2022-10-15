extends PlayerCharacter

var charName = "Ra'Kit"
# Character class, if you end up with any place to put it

# Set up ability lists and populate them with early-game abilities
var attackList = [CombatAbility.new("Shrill Trill", "Does minimal damage to all nearby enemies and lowers their defense.",
				"Self", "Small Donut", false, true, 15, -1.0),
				CombatAbility.new("Throw Dirt", "Deals light damage to an enemy at range. Can inflict Blind.", 
				"Long Range", "One Tile", false, true, 15, -1.5)]
var supportList = [CombatAbility.new("Look Over There!", "The target will step away, but won't take any damage.",
				"Medium Area", "One Tile", false, true, 15, 0)]

func _init():
	# Set stats
	maxHP = 160
	
	bleedResist = 50
	paralResist = 70
	blindResist = 100
	sealResist = 90

	baseAttack = 4
	baseDefense = 4
	baseSpeed = 12
	# Separate magic stats?

func _ready():
	pass
	
#func _process(delta):
#	pass
